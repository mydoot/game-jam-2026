extends RichTextLabel

@onready var shots: RichTextLabel = $"../SHOTS"

@onready var soul: RichTextLabel = $"../SOUL"

@onready var shots_2: RichTextLabel = $"../SHOTS2"

func _ready() -> void:
	text = "[wave amp=30.0 freq=2.5]THANK[/wave]"
	soul.text = "[wave amp=30.0 freq=2.5]THANK[/wave]"
	shots.text = "[wave amp=30.0 freq=2.5]YOU!![/wave]"
	shots_2.text = "[wave amp=30.0 freq=2.5]YOU!![/wave]"
	
	
	visible_ratio = 0
	soul.visible_ratio = 0
	shots.visible_ratio = 0
	shots_2.visible_ratio = 0
	
	var tween = create_tween()
	tween.set_parallel()
	tween.tween_property(self, "visible_ratio", 1.0, 0.5)
	tween.tween_property(soul, "visible_ratio", 1.0, 0.5)
	tween.tween_property(shots, "visible_ratio", 1.0, 0.5)
	tween.tween_property(shots_2, "visible_ratio", 1.0, 0.5)
