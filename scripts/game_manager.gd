extends Node

@onready var ui: Control = $"../UI"
@onready var main: Node3D = $"../main"
@onready var stopwatch: Stopwatch = $"../Stopwatch"
@onready var lap_counter: LapCounter = $"../LapCounter"
@onready var end_screen: CanvasLayer = $"../EndScreen"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	lap_counter.race_finished.connect(game_over)
	print(get_tree().get_root().get_child_count())
	
# Called every frame. 'delta' is the elapsed time since the previous frame.

func _process(delta: float) -> void:
	pass
func game_over():
		
		get_tree().paused
		call_deferred("_change_to_end_screen")

func _change_to_end_screen():
	get_tree().change_scene_to_file("res://scenes/end_screen.tscn")
