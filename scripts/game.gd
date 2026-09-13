extends Node2D
# Main gameplay: unicorn at the bottom catches falling candies, avoids bombs.
# Builds its own scene tree (background, items, player, spawner, UI) in _ready().

@export var base_spawn_interval := 0.8
@export var max_lives := 3

# One life is granted for every this many candies caught (capped at max_lives).
const CANDIES_PER_LIFE := 10
# The unicorn walks this many pixels higher than the base position (all levels).
const PLAYER_Y_OFFSET := -200.0

# Level config (filled from GameGlobals.get_level() in _ready).
var _bomb_chance := 0.15
var _candy_factor := 1.0
var _candy_scale := 1.5
var _level_name := ""

var _score := 0
var _lives := 3
var _candies_caught := 0
var _active := true
var _paused := false

var _candy_tex: Array[Texture2D] = []
var _bomb_tex: Array[Texture2D] = []

var _player: Area2D
var _items_root: Node2D
var _spawner: Timer
var _score_label: Label
var _lives_label: Label
var _level_label: Label
var _pause_button: Button
var _ui_layer: CanvasLayer

func _ready() -> void:
	_load_level()
	_load_textures()
	_build_background()
	_build_items_root()
	_build_player()
	_build_spawner()
	_build_ui()
	_update_hud()
	GameGlobals.load_best()
	AudioManager.play_music("res://assets/audio/music/vivaldi_sonata_gm.mp3")

func _load_level() -> void:
	var lvl: Dictionary = GameGlobals.get_level()
	_level_name = str(lvl.get("name", ""))
	_bomb_chance = float(lvl.get("bomb_chance", 0.15))
	_candy_factor = float(lvl.get("candy_factor", 1.0))
	_candy_scale = float(lvl.get("candy_scale", 1.5))

func _load_textures() -> void:
	for i in 36:
		var t := load("res://assets/sprites/candy/candy_%d.png" % i)
		if t is Texture2D:
			_candy_tex.append(t)
	for i in 6:
		var t := load("res://assets/sprites/enemy/bomb_%d.png" % i)
		if t is Texture2D:
			_bomb_tex.append(t)

func _build_background() -> void:
	var bg := Sprite2D.new()
	bg.name = "Background"
	var tex: Texture2D = load("res://assets/sprites/bg/main_scene.png")
	if tex:
		bg.texture = tex
		var vp := get_viewport_rect().size
		var ts: Vector2 = tex.get_size()
		var s := maxf(vp.x / ts.x, vp.y / ts.y)
		bg.scale = Vector2(s, s)
		bg.position = vp / 2.0
	add_child(bg)

func _build_items_root() -> void:
	_items_root = Node2D.new()
	_items_root.name = "ItemsRoot"
	add_child(_items_root)

func _build_player() -> void:
	var scene: PackedScene = load("res://scenes/player.tscn")
	_player = scene.instantiate()
	add_child(_player)
	var vp := get_viewport_rect().size
	_player.position = Vector2(vp.x / 2.0, vp.y - 220.0 + PLAYER_Y_OFFSET)
	_player.area_entered.connect(_on_player_area_entered)

func _build_spawner() -> void:
	_spawner = Timer.new()
	_spawner.name = "Spawner"
	_spawner.wait_time = base_spawn_interval
	_spawner.autostart = true
	add_child(_spawner)
	_spawner.timeout.connect(_spawn_item)

func _build_ui() -> void:
	_ui_layer = CanvasLayer.new()
	_ui_layer.name = "UI"
	_ui_layer.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(_ui_layer)

	var full := Control.new()
	full.set_anchors_preset(Control.PRESET_FULL_RECT)
	_ui_layer.add_child(full)

	var bar := HBoxContainer.new()
	bar.set_anchors_preset(Control.PRESET_TOP_WIDE)
	bar.offset_left = 28.0
	bar.offset_right = -28.0
	bar.offset_top = 18.0
	bar.offset_bottom = 110.0
	full.add_child(bar)

	_score_label = Label.new()
	_score_label.text = "Счёт: 0"
	_score_label.add_theme_font_size_override("font_size", 46)
	bar.add_child(_score_label)

	_level_label = Label.new()
	_level_label.text = _level_name
	_level_label.add_theme_font_size_override("font_size", 28)
	_level_label.set_anchors_preset(Control.PRESET_TOP_WIDE)
	_level_label.offset_left = 28.0
	_level_label.offset_right = -28.0
	_level_label.offset_top = 116.0
	_level_label.offset_bottom = 156.0
	_level_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	full.add_child(_level_label)

	var sp1 := Control.new()
	sp1.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bar.add_child(sp1)

	_pause_button = Button.new()
	_pause_button.text = "❚❚"
	_pause_button.custom_minimum_size = Vector2(76, 76)
	_pause_button.add_theme_font_size_override("font_size", 34)
	bar.add_child(_pause_button)
	_pause_button.pressed.connect(_toggle_pause)

	var sp2 := Control.new()
	sp2.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bar.add_child(sp2)

	_lives_label = Label.new()
	_lives_label.text = "♥ ♥ ♥"
	_lives_label.add_theme_font_size_override("font_size", 46)
	bar.add_child(_lives_label)

func _update_hud() -> void:
	if _score_label:
		_score_label.text = "Счёт: %d" % _score
	if _lives_label:
		var hearts := ""
		for i in _lives:
			hearts += "♥ "
		_lives_label.text = hearts.strip_edges() if hearts != "" else "—"

# ---------------------------------------------------------------- spawner ---

func _spawn_item() -> void:
	if not _active or _paused:
		return
	var scene: PackedScene = load("res://scenes/falling_item.tscn")
	var item: Area2D = scene.instantiate()
	_items_root.add_child(item)

	var vp := get_viewport_rect().size
	var is_bomb := (randf() < _bomb_chance and _bomb_tex.size() > 0)

	var tex: Texture2D
	var pts := 10
	if is_bomb:
		tex = _bomb_tex[randi() % _bomb_tex.size()]
		pts = 0
	elif _candy_tex.size() > 0 and randf() < _candy_factor:
		tex = _candy_tex[randi() % _candy_tex.size()]
		pts = randi_range(5, 25)
	else:
		# Not a bomb and the candy slot was skipped (level candy factor).
		item.queue_free()
		return

	item.position = Vector2(randf_range(70.0, vp.x - 70.0), -90.0)
	# Difficulty ramps up with score.
	var difficulty := clampf(_score / 600.0, 0.0, 1.0)
	var speed := lerpf(randf_range(240.0, 420.0), randf_range(380.0, 620.0), difficulty)
	item.setup(tex, is_bomb, speed, pts, _candy_scale)

func _on_spawner_tick() -> void:
	# Slightly speed up spawning as score grows.
	var difficulty := clampf(_score / 800.0, 0.0, 1.0)
	_spawner.wait_time = lerpf(base_spawn_interval, 0.45, difficulty)

# ------------------------------------------------------------------ catch ---

func _on_player_area_entered(area: Area2D) -> void:
	if not _active:
		return
	if not (area is Area2D):
		return
	if not area.has_method("setup"):
		return
	if area.is_bomb:
		AudioManager.play_sfx("res://assets/audio/sfx/bomb.wav")
		_flash_screen(Color.RED, 0.35)
		_lose_life()
	else:
		AudioManager.play_sfx("res://assets/audio/sfx/catch.wav")
		_score += int(area.points)
		_candies_caught += 1
		if _candies_caught % CANDIES_PER_LIFE == 0 and _lives < max_lives:
			_lives += 1
			_flash_screen(Color.GREEN, 0.25)
		_on_spawner_tick()
	area.on_caught()
	_update_hud()

func _lose_life() -> void:
	_lives -= 1
	_update_hud()
	if _lives <= 0:
		_end_game()

func _flash_screen(color: Color, alpha: float) -> void:
	var c := ColorRect.new()
	c.color = Color(color, alpha)
	c.set_anchors_preset(Control.PRESET_FULL_RECT)
	c.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_ui_layer.add_child(c)
	var tw := c.create_tween()
	tw.tween_property(c, "color:a", 0.0, 0.5)
	tw.tween_callback(c.queue_free)

func _end_game() -> void:
	_active = false
	_spawner.stop()
	GameGlobals.record_score(_score)
	AudioManager.play_sfx("res://assets/audio/sfx/gameover.wav")
	await get_tree().create_timer(1.1).timeout
	if is_inside_tree():
		get_tree().change_scene_to_file("res://scenes/game_over.tscn")

# ------------------------------------------------------------------- pause ---

func _toggle_pause() -> void:
	_paused = not _paused
	get_tree().paused = _paused
	if _paused:
		AudioManager.stop_music()
		_pause_button.text = "▶"
	else:
		AudioManager.play_music("res://assets/audio/music/vivaldi_sonata_gm.mp3")
		_pause_button.text = "❚❚"
