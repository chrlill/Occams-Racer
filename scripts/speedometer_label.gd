extends Label

@onready var ball: RigidBody3D = $"../../main/Car/Ball"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	text = "%.2f" % (ball.linear_velocity.length() * 3.6) #convert from m/s to km/h
