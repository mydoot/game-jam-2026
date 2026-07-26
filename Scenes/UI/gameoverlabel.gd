extends RichTextLabel

@onready var label_2: RichTextLabel = $"../Label2"

func _ready() -> void:
	text = "[shake rate=10.0 level=15 connected=1]GAME OVER[/shake]"
	
	visible_ratio = 0
	label_2.visible_ratio = 0
	
	var tween = create_tween()
	tween.tween_property(self, "visible_ratio", 1.0, 1)
	
	tween.tween_interval(1)
	
	tween.tween_property(label_2, "visible_ratio", 1.0, 1)
