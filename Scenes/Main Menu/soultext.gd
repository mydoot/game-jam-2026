extends Label

@onready var shots: Label = $SHOTS

func _ready() -> void:
	visible_ratio = 0
	shots.visible_ratio = 0
	
	var tween = create_tween()
	tween.set_parallel()
	tween.tween_property(self, "visible_ratio", 1.0, 0.25)
	tween.tween_property(shots, "visible_ratio", 1.0, 0.25)
