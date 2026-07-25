extends CanvasLayer


signal loading_screen_ready

@export var animation_player: AnimationPlayer

func _ready() -> void:
	await animation_player.animation_finished
	loading_screen_ready.emit()

# The below function can be used to have visuals that change depending on the progress of the scene being loaded (like a progress bar), using the the progress array's 0-1 value
func _on_progress_changed(prog_val: float) -> void:
	pass

func _on_load_finished() -> void:
	animation_player.play_backwards("transition")
	await animation_player.animation_finished
	queue_free()
