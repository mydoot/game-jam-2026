extends CanvasLayer

## Pause overlay instantiated by Player when Stats emits died. It owns the
## restart and quit buttons while allowing itself to process during pause.

## Pauses the active level and keeps this UI responsive.
func _ready() -> void:
	get_tree().paused = true
	process_mode = Node.PROCESS_MODE_ALWAYS


## Restores normal time and reloads the current level back into Planning.
func _on_restart_button_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()
	

## Exits the application from the connected Quit button.
func _on_quit_button_pressed() -> void:
	get_tree().quit()
