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

	var levels_title := Label.new()
	levels_title.text = "ВЫБЕРИ УРОВЕНЬ"
	levels_title.add_theme_font_size_override("font_size", 44)
	levels_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(levels_title)

	var levels_box := VBoxContainer.new()
	levels_box.alignment = BoxContainer.ALIGNMENT_CENTER
	levels_box.add_theme_constant_override("separation", 22)
	vbox.add_child(levels_box)

	for i in GameGlobals.LEVELS.size():
		var lvl: Dictionary = GameGlobals.LEVELS[i]
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 14)
		levels_box.add_child(row)

		var btn := Button.new()
		btn.text = "%d. %s\n%s" % [i + 1, lvl["name"], lvl["desc"]]
		btn.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		btn.custom_minimum_size = Vector2(430, 120)
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn.add_theme_font_size_override("font_size", 34)
		row.add_child(btn)
		btn.pressed.connect(_on_level_pressed.bind(i))

		# Icon hint: how many bombs on this level (or a candy when there are none).
		var icons_box := HBoxContainer.new()
		icons_box.alignment = BoxContainer.ALIGNMENT_CENTER
		icons_box.add_theme_constant_override("separation", 6)
		row.add_child(icons_box)
		for icon_name in lvl.get("icons", []):
			icons_box.add_child(_make_icon(str(GameGlobals.ICON_TEXTURES.get(icon_name, ""))))

func _make_icon(tex_path: String) -> TextureRect:
	var icon := TextureRect.new()
	icon.custom_minimum_size = Vector2(67, 67)
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	if tex_path != "":
		var tex := load(tex_path)
		if tex is Texture2D:
			icon.texture = tex
	return icon

func _on_level_pressed(idx: int) -> void:
	GameGlobals.current_level = idx
	AudioManager.play_sfx("res://assets/audio/sfx/click.wav")
	get_tree().change_scene_to_file("res://scenes/game.tscn")
