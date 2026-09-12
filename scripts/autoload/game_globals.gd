extends Node
# Singleton: holds game state that must survive scene changes.

var last_score := 0
var best_score := 0

func record_score(s: int) -> void:
	last_score = s
	if s > best_score:
		best_score = s
		save_best()

func save_best() -> void:
	var f := FileAccess.open("user://save.cfg", FileAccess.WRITE)
	if f:
		f.store_32(best_score)
		f.close()

func load_best() -> void:
	if FileAccess.file_exists("user://save.cfg"):
		var f := FileAccess.open("user://save.cfg", FileAccess.READ)
		if f:
			best_score = f.get_32()
			f.close()
