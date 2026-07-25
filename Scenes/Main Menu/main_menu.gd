extends Control

## Campaign front door. Continue targets the highest unlocked room, while all
## navigation uses SceneLoader for one consistent covered transition.

## Builds the title screen and focuses the primary action for keyboard use.
func _ready() -> void:
	_build_background()
	var panel := PanelContainer.new()
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.position = Vector2(-230, -270)
	panel.size = Vector2(460, 540)
	add_child(panel)
	var content := VBoxContainer.new()
	content.alignment = BoxContainer.ALIGNMENT_CENTER
	content.add_theme_constant_override("separation", 18)
	panel.add_child(content)
	var title := Label.new()
	title.text = "SIX CHAMBERS"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 48)
	content.add_child(title)
	var subtitle := Label.new()
	subtitle.text = "Plan the cylinder. Break the line of sight."
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	content.add_child(subtitle)
	var continue_button := _menu_button("CONTINUE — LEVEL %d" % GameState.highest_unlocked_level, _continue_game)
	content.add_child(continue_button)
	content.add_child(_menu_button("LEVEL SELECT", _level_select))
	content.add_child(_menu_button("SETTINGS", _settings))
	content.add_child(_menu_button("QUIT", _quit))
	continue_button.grab_focus()

## Adds a dark dungeon-colored backdrop behind the menu.
func _build_background() -> void:
	var background := ColorRect.new()
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	background.color = Color(0.035, 0.04, 0.065)
	add_child(background)

## Creates a consistently sized menu button connected to one callback.
func _menu_button(label: String, callback: Callable) -> Button:
	var button := Button.new()
	button.text = label
	button.custom_minimum_size = Vector2(360, 54)
	button.pressed.connect(callback)
	return button

## Loads the latest unlocked campaign room.
func _continue_game() -> void:
	SfxBus.play_ui(&"click")
	GameState.load_level(GameState.highest_unlocked_level)

## Opens persistent campaign selection.
func _level_select() -> void:
	SfxBus.play_ui(&"click")
	SceneLoader.load_scene(GameState.LEVEL_SELECT)

## Opens the reusable standalone settings screen.
func _settings() -> void:
	SfxBus.play_ui(&"click")
	SceneLoader.load_scene(GameState.SETTINGS)

## Exits only from the explicit main-menu action.
func _quit() -> void:
	get_tree().quit()
