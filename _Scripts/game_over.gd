extends CanvasLayer

## Pause overlay shown when the player dies.

func _ready() -> void:
	get_tree().paused = true
	process_mode = Node.PROCESS_MODE_ALWAYS


## Restores normal time and reloads the active level.
func _on_restart_button_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()
	

## Exits the game from the game-over screen.
func _on_quit_button_pressed() -> void:
	get_tree().quit()
