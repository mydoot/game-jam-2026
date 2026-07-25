extends CanvasLayer

## Transition overlay created by the SceneLoader autoload while another scene
## loads. SceneLoader drives its progress callback and waits for both animations.

signal loading_screen_ready

@export var animation_player: AnimationPlayer
@onready var progress_bar: ProgressBar = $Panel/Center/Progress
var _finishing := false

## Waits for the autoplay entrance transition to cover the current scene, then
## tells SceneLoader that threaded loading can safely begin.
func _ready() -> void:
	await animation_player.animation_finished
	loading_screen_ready.emit()


## Receives SceneLoader's threaded-load progress in the 0-1 range. It is kept as
## an extension point for a future progress bar.
func _on_progress_changed(prog_val: float) -> void:
	if progress_bar:
		progress_bar.value = clampf(prog_val, 0.0, 1.0) * 100.0


## Reveals the newly installed scene, then frees this temporary overlay.
func _on_load_finished() -> void:
	if _finishing:
		return
	_finishing = true
	animation_player.play_backwards("transition")
	await animation_player.animation_finished
	queue_free()
