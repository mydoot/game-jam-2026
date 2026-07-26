extends RichTextLabel


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	modulate.a = 0
	

	var tween := create_tween()
	
	tween.tween_interval(1)
	tween.tween_property(self, "modulate:a", 1, 1).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_SINE)
	
