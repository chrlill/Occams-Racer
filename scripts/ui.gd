extends Control

@onready var stopwatch_label: Label = $Stopwatch_Label
@onready var stopwatch: Stopwatch = $"../Stopwatch"
@onready var speedometer_label: Label = $Speedometer_Label
@onready var lap_count_label: Label = $LapCount_Label
@onready var fastest_lap_label: Label = $LapRecord_Label
@onready var delta_label: Label = $Delta_Label
@onready var previous_lap_time_label: Label = $PreviousLapTime_Label
@onready var lap_counter: LapCounter = $"../LapCounter"
@onready var medal_label: Label = $Medal_Label

@onready var ball: RigidBody3D = $"../main/Car/Ball"

enum MedalRank {
	NONE = 0,
	BRONZE = 1,
	SILVER = 2,
	GOLD = 3
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	stopwatch.get_tree().get_first_node_in_group("stopwatch")
	stopwatch.lap_recorded.connect(update_delta_label)
	stopwatch.lap_recorded.connect(update_lap_count_label)
	stopwatch.lap_recorded.connect(update_previous_lap_time_label)
	stopwatch.lap_recorded.connect(update_fastest_lap_label)
	stopwatch.lap_recorded.connect(update_best_medal)
	
	update_fastest_lap_label()
	update_best_medal()
	update_lap_count_label()
	update_previous_lap_time_label()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	
	update_stopwatch_label()
	update_speedometer_label()

func update_stopwatch_label():
	
	stopwatch_label.text = stopwatch.time_to_string()

func update_speedometer_label():
	speedometer_label.text = "%.0f" % (ball.linear_velocity.length() * 3.6) + " KM/H" #convert from m/s to km/h

func update_lap_count_label():
	
	lap_count_label.text = "Lap " + str(lap_counter.lapCount) + " of " + str(lap_counter.maxLaps)

func update_previous_lap_time_label():	
	
	var lap_times = stopwatch.lapTimeStorageString

	if lap_times.size() <= 1:
		previous_lap_time_label.text = ""
		return

	var display_text = ""
	var valid_laps = lap_times.slice(1, lap_times.size())  # skip index 0
	var laps_to_show = min(valid_laps.size(), 3)

	for i in range(laps_to_show):
		var index = valid_laps.size() - 1 - i
		var lap_number = index + 1  # +2 to account for skipping index 0
		display_text += "Lap %d: %s\n" % [lap_number, valid_laps[index]]

	previous_lap_time_label.text = display_text.strip_edges()

var is_hiding_delta_label := false

func update_delta_label():
	
	var lapDelta = stopwatch.calculateLapTimeDelta()
	var lapCount = stopwatch.lapTimeStorageString.size()

	if lapCount >= 2:
		if lapDelta < 0:
			delta_label.text = "-" + "%.3f" % abs(lapDelta)
			delta_label.add_theme_color_override("font_color", Color(0, 1, 0))
		elif lapDelta > 0:
			delta_label.text = "+" + "%.3f" % abs(lapDelta)
			delta_label.add_theme_color_override("font_color", Color(1, 0, 0))

		if not is_hiding_delta_label:
			hide_delta_label_after_delay()
	else:
		delta_label.text = ""
		delta_label.add_theme_color_override("font_color", Color(1, 1, 1))


func hide_delta_label_after_delay():
	
	is_hiding_delta_label = true
	await get_tree().create_timer(3.0).timeout
	delta_label.text = ""
	is_hiding_delta_label = false
	
func update_fastest_lap_label():
	fastest_lap_label.text = "Fastest Lap: " + stopwatch.get_fastest_lap_string()

func update_best_medal():
	
	var fastest_lap_time = stopwatch.get_fastest_lap()
	var current_medal_rank = MedalRank.NONE
	var medal_text = ''
	
	var best_medal_rank = MedalRank.NONE
	var best_medal_text = " "
	
	if fastest_lap_time == INF:
		medal_text = ""
		current_medal_rank = MedalRank.NONE
	elif fastest_lap_time < 41.5:
		medal_text = "🥇 Gold Medal!"
		current_medal_rank = MedalRank.GOLD
		medal_label.add_theme_color_override("font_color", Color(1, 0.84, 0))  #
	elif fastest_lap_time < 43.0:
		medal_text = "🥈 Silver Medal!"
		current_medal_rank = MedalRank.SILVER
		medal_label.add_theme_color_override("font_color", Color(0.75, 0.75, 0.75)) 
	 # silver color
	elif fastest_lap_time < 44.0:
		medal_text = "🥉 Bronze Medal!"
		current_medal_rank = MedalRank.BRONZE
		medal_label.add_theme_color_override("font_color", Color(0.8, 0.5, 0.2))  # bronze color
	else:
		current_medal_rank = MedalRank.NONE
		medal_text = " "
	
	if current_medal_rank > best_medal_rank:
		best_medal_rank = current_medal_rank
		best_medal_text = medal_text
