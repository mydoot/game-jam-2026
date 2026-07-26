extends Sprite2D

@onready var enemy: Enemy = $".."

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	top_level = true
	
	flip_h = enemy.flip_sprite_horizontally


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	global_rotation = 0
	global_position = get_parent().global_position + Vector2(0,-5.0)
