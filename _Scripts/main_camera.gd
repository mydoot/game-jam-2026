extends Camera2D

## Smooth follow camera used by level scenes. Planning assigns the newly spawned
## Player to target when combat begins.
var target: Node2D

@export_category("Smoothing")
@export var smooth_speed: float = 10.0
@export var mouse_lead: float = 0.2

## Follows target with frame-rate-safe smoothing and a small mouse-direction lead.
func _process(delta: float) -> void:
	if not target:
		return
	
	var blend := clampf(smooth_speed * delta, 0.0, 1.0)
	zoom = zoom.lerp(Vector2(2.25,2.25), blend)
	
	var desired_position = target.global_position
	
	var mouse_offset = get_global_mouse_position() - target.global_position
	desired_position += mouse_offset * mouse_lead
	
	global_position = global_position.lerp(desired_position, blend)
