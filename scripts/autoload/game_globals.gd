extends Node
# Singleton: holds game state that must survive scene changes.

# Level presets (top -> bottom of the menu).
# bomb_chance = share of spawns that are bombs.
# candy_factor = share of would-be candies that actually spawn.
# candy_scale = item size multiplier (candies and bombs, all levels).
const LEVELS: Array = [
	{
		"name": "Без бомб",
		"desc": "Игра вообще без бомб",
		"bomb_chance": 0.0,
		"candy_factor": 1.0,
		"candy_scale": 1.5,
		"icons": ["candy"],
	},
	{
		"name": "Мало бомб",
		"desc": "5% от бомб, 60% конфет",
		"bomb_chance": 0.15 * 0.05,
		"candy_factor": 0.6,
		"candy_scale": 1.5,
		"icons": ["bomb"],
	},
	{
		"name": "Классический",
		"desc": "Стандартные бомбы",
		"bomb_chance": 0.15,
		"candy_factor": 1.0,
		"candy_scale": 1.5,
		"icons": ["bomb", "bomb"],
	},
]

# Menu icons for level rows (name -> sprite). bomb_4 is the round bomb.
const ICON_TEXTURES := {
	"bomb": "res://assets/sprites/enemy/bomb_4.png",
	"candy": "res://assets/sprites/candy/candy_0.png",
}

var current_level := 0
var last_score := 0
var best_score := 0

func get_level() -> Dictionary:
	if current_level < 0 or current_level >= LEVELS.size():
		current_level = 0
	return LEVELS[current_level]

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
