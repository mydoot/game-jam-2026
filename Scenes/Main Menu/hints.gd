extends RichTextLabel

var tween := create_tween()
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visible_ratio = 0
	
	tween.tween_property(self, "visible_ratio", 1, 4)
	
