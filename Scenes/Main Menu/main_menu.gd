extends Node2D

## Main-menu controller. Its Play button delegates the first scene change to the
## SceneLoader autoload so startup uses the same transition as level exits.
## This needs to be the UID of a scene
@export var initial_scene: StringName = &""
@export var start_button: Button


## Starts loading the configured first playable scene.
func _on_button_pressed() -> void:
	if initial_scene == &"":
		push_warning("No initial_scene configured on the main menu.")
		return

	SceneLoader.load_scene(String(initial_scene))
