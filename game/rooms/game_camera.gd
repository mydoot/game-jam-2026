class_name GameCamera
extends Camera2D

@export var smooth_speed := 10.0
@export var mouse_lead := 0.12

var target: Node2D
var following := false

func show_room(center: Vector2, room_size: Vector2) -> void:
	following = false
	global_position = center
	var viewport_size := get_viewport_rect().size
	zoom = Vector2.ONE * minf(viewport_size.x / room_size.x, viewport_size.y / room_size.y) * 0.9

func follow_player(player: Node2D) -> void:
	target = player
	following = true
	zoom = Vector2(1.15, 1.15)

func _process(delta: float) -> void:
	if not following or not is_instance_valid(target):
		return
	var desired := target.global_position
	desired += (get_global_mouse_position() - target.global_position) * mouse_lead
	global_position = global_position.lerp(desired, clampf(smooth_speed * delta, 0.0, 1.0))

