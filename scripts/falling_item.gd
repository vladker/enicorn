extends Area2D
# A single falling object (candy or bomb). Falls down, spins a little,
# self-destructs when it leaves the bottom of the screen.

var is_bomb := false
var speed := 300.0
var points := 10
var _rotation_speed := 0.0
var _dead := false

# Bombs render at this max-dimension so they look candy-sized, not giant.
const BOMB_TARGET_MAX := 80.0
# Collision radius as a fraction of the rendered max-dimension (0.4 => 80% of art radius).
const HITBOX_FRACTION := 0.40

func setup(tex: Texture2D, bomb: bool, spd: float, pts: int) -> void:
	var sprite := $Sprite as Sprite2D
	sprite.texture = tex
	is_bomb = bomb
	speed = spd
	points = pts
	_rotation_speed = randf_range(-1.4, 1.4)
	var tex_max := maxf(tex.get_width(), tex.get_height())
	var rendered_max := tex_max
	if bomb and tex_max > BOMB_TARGET_MAX:
		var s := BOMB_TARGET_MAX / tex_max
		sprite.scale = Vector2(s, s)
		rendered_max = BOMB_TARGET_MAX
	# Hitbox tracks the visible art (slightly smaller = fair, not hollow).
	var r := maxf(20.0, rendered_max * HITBOX_FRACTION)
	var hitbox := $Hitbox as CollisionShape2D
	if hitbox:
		var cshape: CircleShape2D = hitbox.shape as CircleShape2D
		if cshape:
			cshape.radius = r

func _process(delta: float) -> void:
	if _dead:
		return
	position.y += speed * delta
	rotation += _rotation_speed * delta
	if position.y > get_viewport_rect().size.y + 140.0:
		kill()

# Called by the game when the player catches it.
func on_caught() -> void:
	if _dead:
		return
	_dead = true
	var tw := create_tween()
	tw.set_parallel(true)
	tw.tween_property(self, "scale", Vector2(1.7, 1.7), 0.16)
	tw.tween_property(self, "modulate:a", 0.0, 0.16)
	tw.chain().tween_callback(_finish)

func _finish() -> void:
	queue_free()

func kill() -> void:
	queue_free()
