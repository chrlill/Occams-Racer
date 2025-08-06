extends Node3D
@onready var area_3d: Area3D = $Area3D

var lap_count = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_area_3d_area_entered(area: Area3D) -> void:
	lap_count += 1
	print("lap count: " + str(lap_count))
