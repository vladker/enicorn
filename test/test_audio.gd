extends SceneTree

func _initialize() -> void:
	print("=== audio play test (manual AudioManager instance) ===")
	var am_script: GDScript = load("res://scripts/autoload/audio_manager.gd")
	var am = am_script.new()
	root.add_child(am)
	await process_frame

	var fail := 0
	var music := [
		"res://assets/audio/music/vivaldi_sonata_gm.mp3",
		"res://assets/audio/music/menu.wav",
		"res://assets/audio/music/game.wav",
	]
	var sfx := [
		"res://assets/audio/sfx/catch.wav",
		"res://assets/audio/sfx/bomb.wav",
		"res://assets/audio/sfx/gameover.wav",
		"res://assets/audio/sfx/click.wav",
	]
	for p in music:
		if not ResourceLoader.exists(p):
			print("MISSING: " + p)
			fail += 1
			continue
		am.play_music(p, true)
		var st = am._music.stream
		if st is AudioStreamWAV:
			var wav := st as AudioStreamWAV
			print("OK music: %s  loop_mode=%d loop_begin=%d loop_end=%d data=%d calc=%d" % [
				p, wav.loop_mode, wav.loop_begin, wav.loop_end, wav.data.size(), am._wav_total_frames(wav)])
		elif st is AudioStreamMP3:
			print("OK music: %s  loop=%s" % [p, str((st as AudioStreamMP3).loop)])
		elif st is AudioStreamOggVorbis:
			print("OK music: %s  loop=%s" % [p, str((st as AudioStreamOggVorbis).loop)])
		else:
			print("UNEXPECTED: %s -> %s" % [p, st.get_type() if st else "null"])
			fail += 1
	for p in sfx:
		if not ResourceLoader.exists(p):
			print("MISSING: " + p)
			fail += 1
			continue
		am.play_sfx(p)
		print("OK sfx played: " + p)
	am.stop_music()
	print("=== %s ===" % ("ALL AUDIO OK" if fail == 0 else "%d FAIL" % fail))
	quit(fail)
