extends CanvasLayer

## Terminal failure overlay created only by CampaignLevel. It pauses combat and
## routes every action through GameState/SceneLoader to clear pause safely.
@onready var reason_label: Label = $Shade/Panel/Content/Reason

## Pauses the tree while allowing this menu and transitions to keep processing.
func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	get_tree().paused = true

## Sets the human-readable reason after CampaignLevel instantiates the overlay.
func setup(reason: String) -> void:
	if not is_node_ready():
		await ready
	reason_label.text = reason

## Restarts the same level from planning.
func _on_restart_pressed() -> void:
	SfxBus.play_ui(&"click")
	GameState.restart_current_level()

## Returns to the unlocked-level grid.
func _on_level_select_pressed() -> void:
	SfxBus.play_ui(&"click")
	get_tree().paused = false
	SceneLoader.load_scene(GameState.LEVEL_SELECT)

## Returns to the campaign main menu.
func _on_main_menu_pressed() -> void:
	SfxBus.play_ui(&"click")
	get_tree().paused = false
	SceneLoader.load_scene(GameState.MAIN_MENU)
