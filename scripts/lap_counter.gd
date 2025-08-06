extends Node
class_name LapCounter

@onready var finish_line: Area3D = $"../main/FinishLine/Area3D"
@onready var ball: RigidBody3D = $"../main/Car/Ball"

var lapCount = 0
var maxLaps = 3

signal race_finished

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_area_3d_body_entered(body: Node3D) -> void:
	
	if body == ball:
		update_lap_count()
		endRace()
		print(lapCount)
	
func update_lap_count():
	
	if lapCount < 4:
		lapCount += 1
		return lapCount

func endRace():
	
	if lapCount == 4:
		emit_signal("race_finished")
