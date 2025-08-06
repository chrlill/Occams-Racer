extends Node
class_name Stopwatch

@onready var finish_line: Area3D = $"../main/FinishLine/Area3D"
@onready var ball: RigidBody3D = $"../main/Car/Ball"
@onready var lap_counter: LapCounter = $"../LapCounter"

var time = 0.0
var stopped = false
var lapTimeFloat = 0.0
var lapTimeString = " "
var lapTimeStorageString = []
var lapTimeStorageFloat = []
var lapTimeDelta = 0.0

signal lap_recorded

func _process(delta: float) -> void:
	
	if stopped:
		return
	time += delta
	
func reset():
	
	time = 0.0

func time_to_string():
	
	var msec = fmod(time, 1) * 1000
	var sec = fmod(time, 60)
	var minute = time / 60
	#formatting time to look like this 00:00:000
	var format_string = "%02d:%02d.%03d"
	var actual_string = format_string % [minute, sec, msec]
	
	return actual_string

func _on_area_3d_body_entered(body: Node3D) -> void:
	
	if body == ball:	
		addLapTimeToStorage()
		emit_signal("lap_recorded")
		print(str(lapTimeStorageFloat))
		print(calculateLapTimeDelta())
		reset()

func captureLapTime(_format: int):
	
	lapTimeFloat = time
	lapTimeString = time_to_string()
	
	if _format == 0:
		return lapTimeFloat
	elif _format == 1:
		return lapTimeString
		
func addLapTimeToStorage():
	
	lapTimeStorageFloat.append(captureLapTime(0))
	lapTimeStorageString.append(captureLapTime(1))
	
func calculateLapTimeDelta():
	
	if lapTimeStorageFloat.size() >= 3:
		var last_index = lapTimeStorageFloat.size() - 1
		lapTimeDelta = lapTimeStorageFloat[last_index] - lapTimeStorageFloat[last_index - 1]
		return lapTimeDelta
	else:
		return 0.0
	
func get_fastest_lap_string() -> String:
	if lapTimeStorageFloat.size() <= 1:
		return "-:--:---" 
	var fastest_time = lapTimeStorageFloat[1]
	for i in range(2, lapTimeStorageFloat.size()):
		if lapTimeStorageFloat[i] < fastest_time:
			fastest_time = lapTimeStorageFloat[i]
			
	var msec = int(fmod(fastest_time, 1) * 1000)
	var sec = int(fmod(fastest_time, 60))
	var minute = int(fastest_time / 60)
	var format_string = "%02d:%02d:%03d"
	return format_string % [minute, sec, msec]
	
func get_fastest_lap() -> float:
	if lapTimeStorageFloat.size() <= 1:
		return INF
	var fastest_time = lapTimeStorageFloat[1]
	for i in range(2, lapTimeStorageFloat.size()):
		if lapTimeStorageFloat[i] < fastest_time:
			fastest_time = lapTimeStorageFloat[i]
	return fastest_time
