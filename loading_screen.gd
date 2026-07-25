extends CanvasLayer

## Transition overlay used by SceneLoader while the next scene loads.

signal loading_screen_ready

@export var animation_player: AnimationPlayer

func _ready() -> void:
	await animation_player.animation_finished
	loading_screen_ready.emit()


## Receives load progress in the 0-1 range for future progress visuals.
func _on_progress_changed(_prog_val: float) -> void:
	pass


## Plays the transition out before freeing the loading overlay.
func _on_load_finished() -> void:
	animation_player.play_backwards("transition")
	await animation_player.animation_finished
	queue_free()
