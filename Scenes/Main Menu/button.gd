extends Button


var tween := create_tween()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	
	pivot_offset = size / 2
	
	modulate.a = 0

	tween.set_parallel(true)
	tween.tween_property(self, "modulate:a", 1, 2).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	


func _on_mouse_entered() -> void:
	reset_tween()

	tween.tween_property(self, "scale", Vector2(1.3, 1.3), 1).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CIRC)


func _on_mouse_exited() -> void:
	reset_tween()
	
	tween.tween_property(self, "scale", Vector2(1, 1), 0.2).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CIRC)


func reset_tween() -> void:
	if tween:
		tween.kill()
	tween = create_tween()
