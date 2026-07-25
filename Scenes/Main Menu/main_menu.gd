extends Node2D

## Main menu controller that starts the first configured scene through the
## shared loading-screen flow.
## This needs to be the UID of a scene
@export var initial_scene: StringName = &""
@export var start_button: Button


## Starts loading the configured first playable scene.
func _on_button_pressed() -> void:
	if initial_scene == &"":
		push_warning("No initial_scene configured on the main menu.")
		return

	SceneLoader.load_scene(String(initial_scene))
