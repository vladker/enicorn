extends Control
# Main menu: title, best score, Play button. UI is built in code.

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
	overlay.color = Color(0.0, 0.0, 0.0, 0.35)
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(overlay)

	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(center)

	var vbox := VBoxContainer.new()
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_theme_constant_override("separation", 44)
	center.add_child(vbox)

	var title := Label.new()
	title.text = "ЕДИНОРОГ"
	title.add_theme_font_size_override("font_size", 96)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title)

	var subtitle := Label.new()
	subtitle.text = "Лови конфеты, уклоняйся от бомб!"
	subtitle.add_theme_font_size_override("font_size", 36)
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(subtitle)

	var best := Label.new()
	best.text = "Рекорд: %d" % GameGlobals.best_score
	best.add_theme_font_size_override("font_size", 40)
	best.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(best)

	var play := Button.new()
	play.text = "ИГРАТЬ"
	play.custom_minimum_size = Vector2(420, 120)
	play.add_theme_font_size_override("font_size", 54)
	vbox.add_child(play)
	play.pressed.connect(_on_play_pressed)

func _on_play_pressed() -> void:
	AudioManager.play_sfx("res://assets/audio/sfx/click.wav")
	get_tree().change_scene_to_file("res://scenes/game.tscn")
