extends Area2D
# The unicorn: moves along the bottom, follows pointer/touch or arrow keys,
# plays a small walk animation while moving.

@export var move_speed := 900.0

var _frames: Array[Texture2D] = []
var _shown_frame := -1
var _anim_time := 0.0
var _moving := false
var _facing_right := true
var _pointer_down := false
var _pointer_x := -1.0
var _half_w := 130.0

func _ready() -> void:
	# Load the 8 unicorn frames.
	for i in 8:
		var t := load("res://assets/sprites/unicorn/unicorn_%d.png" % i)
		if t is Texture2D:
			_frames.append(t)
	if _frames.size() > 0:
		$Sprite.texture = _frames[0]
		_shown_frame = 0
		_half_w = maxf(120.0, _frames[0].get_width() * 0.5)

func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed:
			_pointer_down = true
			_pointer_x = event.position.x
		else:
			_pointer_down = false
	elif event is InputEventScreenDrag:
		_pointer_x = event.position.x
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		_pointer_down = event.pressed
		if event.pressed:
			_pointer_x = event.position.x
	elif event is InputEventMouseMotion and _pointer_down:
		_pointer_x = event.position.x

func _process(delta: float) -> void:
	var dir := 0.0
	if Input.is_physical_key_pressed(KEY_LEFT) or Input.is_physical_key_pressed(KEY_A):
		dir -= 1.0
	if Input.is_physical_key_pressed(KEY_RIGHT) or Input.is_physical_key_pressed(KEY_D):
		dir += 1.0

	if dir != 0.0:
		position.x += dir * move_speed * delta
		_moving = true
		_facing_right = dir > 0.0
	elif _pointer_down and _pointer_x >= 0.0:
		var diff := _pointer_x - position.x
		if absf(diff) > 2.0:
			_moving = true
			_facing_right = diff > 0.0
			var step := minf(absf(diff), move_speed * delta)
			position.x += signf(diff) * step
		else:
			_moving = false
	else:
		_moving = false

	var vw := get_viewport_rect().size.x
	position.x = clampf(position.x, _half_w, vw - _half_w)

	_animate(delta)
	$Sprite.flip_h = not _facing_right

func _animate(delta: float) -> void:
	if _frames.is_empty():
		return
	if _moving:
		_anim_time += delta
		var fps := 12.0
		var idx := int(_anim_time * fps) % _frames.size()
		if idx != _shown_frame:
			_shown_frame = idx
			$Sprite.texture = _frames[idx]
	else:
		_anim_time = 0.0
		if _shown_frame != 0:
			_shown_frame = 0
			$Sprite.texture = _frames[0]
