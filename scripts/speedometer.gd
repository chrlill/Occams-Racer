extends Label

@onready var ball: RigidBody3D = $"../Car/Ball"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func speedometer():
	
	Label.text = str(ball.linear_velocity.length())
