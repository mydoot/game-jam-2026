@tool
class_name SolidWall
extends StaticBody2D

@export var size := Vector2(64, 64):
	set(value):
		size = value
		_apply_size()

func _ready() -> void:
	_apply_size()

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

