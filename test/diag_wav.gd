extends SceneTree

func _initialize() -> void:
	print("=== AudioStreamWAV diagnostics ===")
	var p := "res://assets/audio/music/menu.wav"
	var res = load(p)
	print("type = " + res.get_type())
	var props: Array = res.get_property_list()
	print("--- properties ---")
	for pr in props:
		var name: String = pr["name"]
		if name in ["loop", "loop_begin", "loop_end", "loop_mode", "data", "stereo", "mix_rate", "format", "loop_playback_time"]:
			var flags: int = pr["usage"]
			var can_write := (flags & 2) != 0  # PROPERTY_USAGE_SETTER
			var can_read := (flags & 1) != 0   # PROPERTY_USAGE_GETTER
			print("  %s  read=%s write=%s value=%s" % [name, can_read, can_write, str(pr.get("hint_string", ""))])
	print("--- has_method ---")
	for m in ["get_length_frames", "get_length", "loop", "get_loop_end", "get_loop_begin"]:
		print("  has_method(%s) = %s" % [m, res.has_method(m)])
	quit(0)
