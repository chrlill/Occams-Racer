extends Node3D

@onready var Ball: RigidBody3D = $Ball
@onready var Car: Node3D = $CarModel
@onready var CarBody: MeshInstance3D = $"CarModel/race-future/body"
@onready var BoostTimer: Timer = $BoostTimer
@onready var DriftTimer: Timer = $DriftTimer
@onready var MinimumDriftTimer: Timer = $MinimumDriftTimer
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var engine_sound: AudioStreamPlayer3D = $CarModel/EngineSound
@onready var boost_sound: AudioStreamPlayer3D = $CarModel/BoostSound

@onready var camera_pivot: Node3D = $CarModel/CameraPivot
@onready var camera_3d: Camera3D = $CarModel/CameraPivot/Camera3D
@onready var static_body_3d_rails: StaticBody3D = $"../map/track2/Untitled_Imported/StaticBody3D_Rails"

@export var base_lead := 12.0
@export var drift_lead := 16.0

var smooth_steer = 0.0
var current_look_lead_offset = Vector3.ZERO

@export var acceleration = 300.0
@export var off_throttle = 275.0
@export var brake_force = 25.0
@export var steering = 12.0
@export var turn_speed = 3.0
var body_tilt = 30

var speed_input = 0
var rotate_input = 0

var Drifting = false
var DriftDirection = 0
var MinimumDrift = false
var Boost = 1

var wall_hit = false

var camera_look_target: Vector3

func _ready():
	camera_look_target = Car.global_position

func _physics_process(delta: float) -> void:
	
	var inAir = false
	Ball.contact_monitor = true
	Ball.max_contacts_reported = 16
		
	if Ball.get_contact_count() < 1:
		inAir = true
	
	if !inAir:
		Ball.apply_central_force(-Car.global_transform.basis.z * speed_input * Boost)
	else:
		Ball.apply_central_force(-Car.global_transform.basis.z * speed_input * 0.6)
	
	var target_steer = Input.get_action_strength("SteerRight") - Input.get_action_strength("SteerLeft")
	smooth_steer = lerp(smooth_steer, target_steer, delta * 5.0)  # Lower this number for slower snapback

	var car_right = Car.global_transform.basis.x.normalized()
	var drift_blend = 0
	var lead_amount = lerp(base_lead, drift_lead, drift_blend)
	
	if Drifting:
		drift_blend = clamp(abs(smooth_steer), 0, 1)
	else:
		drift_blend = 0
	
	var look_lead_offset = car_right * smooth_steer * lead_amount

	var target = Car.global_position + Ball.linear_velocity + look_lead_offset
	
	camera_look_target = camera_look_target.lerp(target, delta * 1.5)
	camera_3d.look_at(camera_look_target, Vector3.UP)
	camera_pivot.global_position = camera_pivot.global_position.lerp(Car.global_position + look_lead_offset * 0.2,
				delta * 5.0)
				
	if Ball.linear_velocity.length() < -0.01:
		camera_look_target = camera_look_target.lerp(-target, delta * 1.5)
	
func _process(delta: float) -> void:
	
	handleSound()
	
	Car.global_transform.origin = lerp(Car.global_transform.origin, Ball.global_transform.origin, delta * 10.0)
	
	if Ball.linear_velocity.length() > 1.2:
		RotateCar(delta)
		
	if Input.is_action_just_pressed("Drift") and not Drifting and rotate_input != 0 and speed_input > 0:
		StartDrift()
		
	var drift_steering_modifier := 1.2

	if Drifting:
		
		var DriftAmount := (Input.get_action_strength("SteerLeft") - Input.get_action_strength("SteerRight"))
		DriftAmount *= deg_to_rad(steering * drift_steering_modifier)
		rotate_input = DriftAmount
		
		var handbrake = -Input.get_action_strength("Drift") * brake_force
		handbrake *= lerp(0, -5, 10 * delta)
		speed_input = handbrake
		
	else:
		rotate_input = deg_to_rad(steering) * (Input.get_action_strength("SteerLeft") - Input.get_action_strength("SteerRight"))
		speed_input = (Input.get_action_strength("Accelerate") * acceleration) - (Input.get_action_strength("Brake") * brake_force)
		
		if Input.is_action_just_released("Accelerate"):
			speed_input = (Input.get_action_strength("Accelerate") * off_throttle) - (Input.get_action_strength("Brake") * brake_force)
	
	if Drifting and (Input.is_action_just_released("Drift") or speed_input < 1):
		StopDrift()
	
	#print("Velocity: " + str(Ball.linear_velocity.length()))	
	#print("isDrifting: " + str(Drifting))
	#print("MinimumDrift: " + str(MinimumDrift))
	#print("Boost: " + str(Boost))
	#print("DriftTimer: " + str(1 - DriftTimer.time_left))
	#print("rotate_input: " + str(rotate_input))
	#print(body_tilt)
		
func RotateCar(delta):
	
	var speed = Ball.linear_velocity.length()
	var min_tilt = 1.0
	var max_tilt = 0.0
	
	if Drifting:
		max_tilt = 2.4
	else: 
		max_tilt = 2.0
	
	var tilt_strength = lerp(min_tilt, max_tilt, clamp(speed / 50.0, 0, 1))
	var t = -rotate_input * tilt_strength
	var new_basis = Car.global_transform.basis.rotated(Car.global_transform.basis.y, rotate_input)
	
	Car.global_transform.basis = Car.global_transform.basis.slerp(new_basis, turn_speed * delta)
	Car.global_transform = Car.global_transform.orthonormalized()
	CarBody.rotation.x = lerp(CarBody.rotation.x, t, 10 * delta)
	
	
func StartDrift():
	Drifting = true
	MinimumDrift = false
	DriftDirection = rotate_input
	MinimumDriftTimer.start()
	DriftTimer.start()
	
func StopDrift():
	
	if MinimumDrift:
		Boost = Boost + (remap(DriftTimer.time_left, 1, 0, 0, 0.5))
		BoostTimer.start()
		animation_player.play("BoostCam", 0.3)
		animation_player.queue("BoostCamZoomIn")
		boost_sound.play()
		
	Drifting = false
	MinimumDrift = false	
		
func _on_minimum_drift_timer_timeout() -> void:
	if Drifting: 
		MinimumDrift = true

func _on_boost_timer_timeout() -> void:
	Boost = 1.0
	
func handleSound():
	var newVal = (Ball.linear_velocity.length() / 120) + 0.4
	engine_sound.set_pitch_scale(newVal)
