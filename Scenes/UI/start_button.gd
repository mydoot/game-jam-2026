extends Button

@onready var hover_sfx: AudioStreamPlayer2D = $"../../../../HoverSFX"


var tween := create_tween()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	
	add_theme_color_override("font_color", Color.WHITE)


func _on_mouse_entered() -> void:
	reset_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "scale", Vector2(1.1, 1.1), 0.2).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
	#tween.tween_property(self, "theme_override_colors/font_color", Color.RED, 0.2).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
	hover_sfx.play()


func _on_mouse_exited() -> void:
	reset_tween()
	tween.set_parallel(true)
	#tween.tween_property(self, "theme_override_colors/font_color", Color.WHITE, 0.2).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
	tween.tween_property(self, "scale", Vector2(1, 1), 0.2).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)

func reset_tween() -> void:
	if tween:
		tween.kill()
	tween = create_tween()
