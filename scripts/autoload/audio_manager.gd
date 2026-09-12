extends Node
# Singleton: plays music (one voice) and SFX (pool of voices).
# All calls are safe no-ops if the audio file does not exist yet.

const MAX_SFX := 8

var _music: AudioStreamPlayer
var _sfx_pool: Array = []

func _ready() -> void:
	_music = AudioStreamPlayer.new()
	_music.bus = "Master"
	_music.volume_db = -6.0
	add_child(_music)
	for i in MAX_SFX:
		var p := AudioStreamPlayer.new()
		p.bus = "Master"
		add_child(p)
		_sfx_pool.append(p)

func _load(path: String) -> AudioStream:
	if path.is_empty():
		return null
	if not ResourceLoader.exists(path):
		return null
	var res := load(path)
	return res if res is AudioStream else null

func play_music(path: String, loop := true) -> void:
	var stream := _load(path)
	if stream == null:
		return
	if _music.stream == stream and _music.playing:
		return
	if loop:
		if stream is AudioStreamOggVorbis:
			(stream as AudioStreamOggVorbis).loop = true
		elif stream is AudioStreamMP3:
			(stream as AudioStreamMP3).loop = true
		elif stream is AudioStreamWAV:
			_enable_wav_loop(stream as AudioStreamWAV)
	_music.stream = stream
	if not _music.playing:
		_music.play()

func _enable_wav_loop(wav: AudioStreamWAV) -> void:
	# Godot 4 AudioStreamWAV has no `loop` bool; it uses loop_mode + bounds.
	wav.loop_begin = 0
	wav.loop_end = _wav_total_frames(wav)
	wav.loop_mode = AudioStreamWAV.LOOP_FORWARD

func _wav_total_frames(wav: AudioStreamWAV) -> int:
	var bytes_per_sample := 2
	match int(wav.format):
		0:  # FORMAT_8_BITS
			bytes_per_sample = 1
		1:  # FORMAT_16_BITS
			bytes_per_sample = 2
		_:
			bytes_per_sample = 2
	var channels := 2 if wav.stereo else 1
	var denom := bytes_per_sample * channels
	if denom <= 0:
		return 0
	return wav.data.size() / denom

func stop_music() -> void:
	_music.stop()

func play_sfx(path: String, volume_db := 0.0) -> void:
	var stream := _load(path)
	if stream == null:
		return
	# Find a free voice; if all busy, reuse the first.
	var player: AudioStreamPlayer = null
	for p in _sfx_pool:
		if not p.playing:
			player = p
			break
	if player == null:
		player = _sfx_pool[0]
	player.stream = stream
	player.volume_db = volume_db
	player.play()
