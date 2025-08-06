extends CanvasLayer

@onready var try_again: Button = $"Rows/Try Again"
@onready var exit: Button = $Rows/Exit
@onready var medal_label: Label = $MedalText
@onready var lap_counter: LapCounter = $LapCounter
@onready var stopwatch: Node = $Stopwatch

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _on_try_again_pressed() -> void:

	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func _on_exit_pressed() -> void:
	get_tree().quit()

func _on_race_finished() -> void:
	
	_update_medal()
	
func _update_medal():
	
	medal_label.text = "Fastest Lap: " + stopwatch.get_fastest_lap_string()
