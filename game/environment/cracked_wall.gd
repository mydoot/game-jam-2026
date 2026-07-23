@tool
class_name DestructibleWall
extends StaticBody2D

signal destroyed(wall: DestructibleWall)

@export var size := Vector2(64, 64):
	set(value):
		size = value
		_apply_size()

var is_destroyed := false

func _ready() -> void:
	add_to_group("destructible_terrain")
	_apply_size()

func destroy() -> void:
	if is_destroyed:
		return
	is_destroyed = true
	collision_layer = 0
	$CollisionShape2D.set_deferred("disabled", true)
	destroyed.emit(self)
	queue_free()

func _apply_size() -> void:
	if not is_node_ready():
		return
	var shape := ($CollisionShape2D as CollisionShape2D).shape as RectangleShape2D
	shape.size = size
	($Visual as Polygon2D).polygon = PackedVector2Array([
		size * -0.5,
		Vector2(size.x, -size.y) * 0.5,
		size * 0.5,
		Vector2(-size.x, size.y) * 0.5,
	])
	($CrackA as Line2D).points = PackedVector2Array([size * -0.5, size * 0.5])
	($CrackB as Line2D).points = PackedVector2Array([
		Vector2(size.x, -size.y) * 0.5,
		Vector2(-size.x, size.y) * 0.5,
	])

