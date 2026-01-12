extends Node

var _start_ms: int = 0
var _ended := false

var _path := "C:/Users/gameuser/Desktop/RumbleTumbleRobots/results.csv"

func _ready():
	_start_ms = Time.get_ticks_msec()

func end_match(winner_name: String, blue_dodge_cooldown: float) -> void:
	if _ended:
		return
	_ended = true

	var t := (Time.get_ticks_msec() - _start_ms) / 1000.0

	DirAccess.make_dir_recursive_absolute("C:/Users/gameuser/Desktop/RumbleTumbleRobots")

	var file: FileAccess
	if FileAccess.file_exists(_path):
		file = FileAccess.open(_path, FileAccess.READ_WRITE)
		if file == null:
			return
		file.seek_end()
	else:
		file = FileAccess.open(_path, FileAccess.WRITE)
		if file == null:
			return
		file.store_string("timestamp_unix,winner,time_s,blue_dodge_cooldown\n")

	var ts := int(Time.get_unix_time_from_system())
	file.store_string("%d,%s,%.3f,%.3f\n" % [ts, winner_name, t, blue_dodge_cooldown])
	file.close()
