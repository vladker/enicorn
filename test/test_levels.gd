extends SceneTree
# Checks: life every 10 candies + the 3 level presets (icons, sizes, player height).
var _failures := 0

func _icons_eq(a: Variant, b: Array) -> bool:
	if a.size() != b.size():
		return false
	for i in a.size():
		if str(a[i]) != str(b[i]):
			return false
	return true

func _check(cond: bool, ok_msg: String, fail_msg: String) -> void:
	if cond:
		print("PASS: " + ok_msg)
	else:
		print("FAIL: " + fail_msg)
		_failures += 1

func _initialize() -> void:
	print("=== Enicorn levels test ===")
	var gg = root.get_node("GameGlobals")
	var scene: PackedScene = load("res://scenes/game.tscn")
	var game = scene.instantiate()
	root.add_child(game)
	await process_frame
	await process_frame

	# Level 0 (no bombs, top of menu)
	_check(game._bomb_chance == 0.0, "level0 bomb_chance 0", "level0 bomb_chance=%f" % game._bomb_chance)
	_check(absf(game._candy_scale - 1.5) < 0.0001, "level0 candy_scale 1.5", "level0 candy_scale=%f" % game._candy_scale)
	_check(game._level_name == "Без бомб", "level0 name", "level0 name=%s" % game._level_name)

	# Life every 10 candies (capped at max_lives)
	game._lives = 1  # leave headroom so the grant path runs
	var lives0: int = game._lives
	var item_scene: PackedScene = load("res://scenes/falling_item.tscn")
	for i in 10:
		var candy = item_scene.instantiate()
		game._items_root.add_child(candy)
		candy.setup(game._candy_tex[0], false, 300.0, 10)
		game._on_player_area_entered(candy)
		await process_frame
	_check(game._lives == lives0 + 1, "10 candies -> +1 life (%d -> %d)" % [lives0, game._lives], "lives did not grow (%d -> %d)" % [lives0, game._lives])

	# Candy item scaled 1.5x
	var candy = item_scene.instantiate()
	game._items_root.add_child(candy)
	candy.setup(game._candy_tex[0], false, 300.0, 10, 1.5)
	await process_frame
	_check(absf(candy.get_node("Sprite").scale.x - 1.5) < 0.001, "candy sprite scaled 1.5x", "candy scale=%f" % candy.get_node("Sprite").scale.x)

	# Level 1: few bombs (5% of 15%), 60% candies, 1.5x size
	gg.current_level = 1
	var g1 = scene.instantiate()
	root.add_child(g1)
	await process_frame
	_check(absf(g1._bomb_chance - 0.15 * 0.05) < 0.000001, "level1 bomb_chance 0.75%", "level1 bomb_chance=%f" % g1._bomb_chance)
	_check(absf(g1._candy_factor - 0.6) < 0.000001, "level1 candy_factor 0.6", "level1 candy_factor=%f" % g1._candy_factor)
	_check(absf(g1._candy_scale - 1.5) < 0.0001, "level1 candy_scale 1.5", "level1 candy_scale=%f" % g1._candy_scale)

	# Level 2: classic (standard bombs), 1.5x size
	gg.current_level = 2
	var g2 = scene.instantiate()
	root.add_child(g2)
	await process_frame
	_check(absf(g2._bomb_chance - 0.15) < 0.000001, "level2 bomb_chance 0.15", "level2 bomb_chance=%f" % g2._bomb_chance)
	_check(absf(g2._candy_factor - 1.0) < 0.000001, "level2 candy_factor 1.0", "level2 candy_factor=%f" % g2._candy_factor)
	_check(absf(g2._candy_scale - 1.5) < 0.0001, "level2 candy_scale 1.5", "level2 candy_scale=%f" % g2._candy_scale)

	# Unicorn 200px higher on ALL levels
	var vp := root.get_viewport().get_visible_rect().size
	var want_y: float = vp.y - 220.0 - 200.0
	for g in [game, g1, g2]:
		_check(absf(g._player.position.y - want_y) < 0.01, "player 200px higher (y=%f, want %f)" % [g._player.position.y, want_y], "player y=%f want %f" % [g._player.position.y, want_y])

	# Level 0 spawns no bombs
	gg.current_level = 0
	var g0 = scene.instantiate()
	root.add_child(g0)
	await process_frame
	var spawned_bombs := 0
	for i in 200:
		g0._spawn_item()
		await process_frame
	for it in g0._items_root.get_children():
		if it.has_method("setup") and it.is_bomb:
			spawned_bombs += 1
	_check(spawned_bombs == 0, "level0 spawns no bombs in 200 spawns", "level0 spawned %d bombs" % spawned_bombs)

	# Menu icons config: candy / bomb / bomb+bomb
	var l0: Dictionary = gg.LEVELS[0]
	var l1: Dictionary = gg.LEVELS[1]
	var l2: Dictionary = gg.LEVELS[2]
	_check(_icons_eq(l0["icons"], ["candy"]), "level0 icons [candy]", "level0 icons=%s" % str(l0["icons"]))
	_check(_icons_eq(l1["icons"], ["bomb"]), "level1 icons [bomb]", "level1 icons=%s" % str(l1["icons"]))
	_check(_icons_eq(l2["icons"], ["bomb", "bomb"]), "level2 icons [bomb bomb]", "level2 icons=%s" % str(l2["icons"]))
	_check(ResourceLoader.exists(gg.ICON_TEXTURES["bomb"]), "bomb icon exists", "bomb icon missing")
	_check(ResourceLoader.exists(gg.ICON_TEXTURES["candy"]), "candy icon exists", "candy icon missing")

	_finish()

func _finish() -> void:
	print("=== %s ===" % ("ALL TESTS PASSED" if _failures == 0 else "%d FAILURE(S)" % _failures))
	quit(_failures)
