extends Label

@onready var planning: Node2D = $"../.."

func _ready() -> void:
	visible_ratio = 0

	text = planning.level_name
	
	var tween = create_tween()
	
	tween.tween_interval(0.75)
	
	tween.tween_property(self, "visible_ratio", 1.0, 1)
	
	tween.tween_interval(3)
	
	tween.tween_property(self, "modulate:a", 0, 0.75)
	
	tween.tween_callback(queue_free)
