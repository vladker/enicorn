extends SceneTree
# Headless white-box test for core game logic.
# Run: godot --headless --path <proj> -s res://test/test_logic.gd

var _failures := 0

func _check(cond: bool, ok_msg: String, fail_msg: String) -> void:
	if cond:
		print("PASS: " + ok_msg)
	else:
		print("FAIL: " + fail_msg)
		_failures += 1

func _initialize() -> void:
	print("=== Enicorn logic test ===")
	var scene: PackedScene = load("res://scenes/game.tscn")
	var game = scene.instantiate()
	root.add_child(game)
	await process_frame
	await process_frame

	# Preconditions
	_check(game._candy_tex.size() > 0, "candy textures loaded (%d)" % game._candy_tex.size(), "no candy textures loaded")
	_check(game._bomb_tex.size() > 0, "bomb textures loaded (%d)" % game._bomb_tex.size(), "no bomb textures loaded")
	_check(game._player != null and game._player.has_method("_animate"), "player built", "player missing")
	if game._candy_tex.is_empty() or game._bomb_tex.is_empty():
		_finish()
		return

	var item_scene: PackedScene = load("res://scenes/falling_item.tscn")

	# Test 1: catching a candy increases score
	var score_before: int = game._score
	var candy = item_scene.instantiate()
	game._items_root.add_child(candy)
	candy.setup(game._candy_tex[0], false, 300.0, 25)
	game._on_player_area_entered(candy)
	await process_frame
	_check(game._score == score_before + 25, "candy catch -> score +%d" % 25, "candy catch did not add score (before=%d after=%d)" % [score_before, game._score])

	# Test 2: catching a bomb removes a life
	var lives_before: int = game._lives
	var bomb = item_scene.instantiate()
	game._items_root.add_child(bomb)
	bomb.setup(game._bomb_tex[0], true, 300.0, 0)
	game._on_player_area_entered(bomb)
	await process_frame
	_check(game._lives == lives_before - 1, "bomb catch -> lives -1", "bomb catch did not remove a life (before=%d after=%d)" % [lives_before, game._lives])

	# Test 3: losing all lives sets active=false path (drive lives to 0)
	while game._lives > 0 and game._active:
		var b = item_scene.instantiate()
		game._items_root.add_child(b)
		b.setup(game._bomb_tex[0], true, 300.0, 0)
		game._on_player_area_entered(b)
		await process_frame
	_check(game._lives <= 0, "lives can reach 0", "lives did not reach 0")
	_check(game._active == false, "game ends (active=false) at 0 lives", "game did not end at 0 lives")

	_finish()

func _finish() -> void:
	print("=== %s ===" % ("ALL TESTS PASSED" if _failures == 0 else "%d FAILURE(S)" % _failures))
	quit(_failures)
