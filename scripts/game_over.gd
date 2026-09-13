extends Control
# Game over screen: final score, best score, Restart and Menu buttons.

func _ready() -> void:
	GameGlobals.load_best()
	AudioManager.play_music("res://assets/audio/music/vivaldi_sonata_gm.mp3")
	_build_ui()

func _build_ui() -> void:
	var bg := TextureRect.new()
	var tex := load("res://assets/sprites/bg/main_scene.png")
	if tex:
		bg.texture = tex
		bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		bg.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	var overlay := ColorRect.new()
	overlay.color = Color(0.0, 0.0, 0.0, 0.55)
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(overlay)

	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(center)

	var vbox := VBoxContainer.new()
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_theme_constant_override("separation", 38)
	center.add_child(vbox)

	var title := Label.new()
	title.text = "ИГРА ОКОНЧЕНА"
	title.add_theme_font_size_override("font_size", 72)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title)

	var level := Label.new()
	level.text = "Уровень: %s" % GameGlobals.get_level()["name"]
	level.add_theme_font_size_override("font_size", 34)
	level.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(level)

	var score := Label.new()
	score.text = "Ваш счёт: %d" % GameGlobals.last_score
	score.add_theme_font_size_override("font_size", 54)
	score.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(score)

	var best := Label.new()
	best.text = "Рекорд: %d" % GameGlobals.best_score
	best.add_theme_font_size_override("font_size", 40)
	best.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(best)

	var restart := Button.new()
	restart.text = "ЗАНОВО"
	restart.custom_minimum_size = Vector2(400, 110)
	restart.add_theme_font_size_override("font_size", 48)
	vbox.add_child(restart)
	restart.pressed.connect(_on_restart_pressed)

	var menu := Button.new()
	menu.text = "В МЕНЮ"
	menu.custom_minimum_size = Vector2(400, 110)
	menu.add_theme_font_size_override("font_size", 48)
	vbox.add_child(menu)
	menu.pressed.connect(_on_menu_pressed)

func _on_restart_pressed() -> void:
	AudioManager.play_sfx("res://assets/audio/sfx/click.wav")
	get_tree().change_scene_to_file("res://scenes/game.tscn")

func _on_menu_pressed() -> void:
	AudioManager.play_sfx("res://assets/audio/sfx/click.wav")
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
