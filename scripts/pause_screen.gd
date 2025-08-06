extends Control
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	$AnimationPlayer.play("RESET")
	hide()

func pause():
	show()
	$AnimationPlayer.play("blur")
	get_tree().paused = true  # Pause *after* playing animation
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func resume():
	get_tree().paused = false  # Unpause first so animation can play
	$AnimationPlayer.play_backwards("blur")
	await $AnimationPlayer.animation_finished
	hide()
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
func testEsc():
	if Input.is_action_just_pressed("Pause") and !get_tree().paused:
		pause()
		print(get_tree().paused)
	elif Input.is_action_just_pressed("Pause") and get_tree().paused:
		resume()
		print(get_tree().paused)

func _on_resume_pressed() -> void:
	resume()

func _on_restart_pressed() -> void:
	resume()
	get_tree().reload_current_scene()

func _on_quit_pressed() -> void:
	get_tree().quit()

func _unhandled_input(event):
	
	if event.is_action_pressed("Pause"):
		if get_tree().paused:
			resume()
		else:
			pause()
