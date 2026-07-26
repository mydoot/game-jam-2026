extends Control

## Final campaign screen reporting completion and offering replay/navigation.

## Builds the victory summary and actions.
func _ready() -> void:
	SfxBus.play_ui(&"victory")
	var background := ColorRect.new()
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	background.color = Color(0.025, 0.035, 0.055)
	add_child(background)
	var box := VBoxContainer.new()
	box.set_anchors_preset(Control.PRESET_CENTER)
	box.position = Vector2(-260, -220)
	box.size = Vector2(520, 440)
	background.add_child(box)
	var title := Label.new()
	title.text = "ALL CHAMBERS CLEARED"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 40)
	box.add_child(title)
	var summary := Label.new()
	summary.text = "You planned the cylinder and escaped the dungeon.\nCleared rooms: %d / 6" % GameState.completed_levels.size()
	summary.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(summary)
	box.add_child(_button("REPLAY FINAL CHAMBER", func(): _navigate("", 6)))
	box.add_child(_button("LEVEL SELECT", func(): _navigate(GameState.LEVEL_SELECT)))
	box.add_child(_button("MAIN MENU", func(): _navigate(GameState.MAIN_MENU)))

## Creates one consistently sized action button.
func _button(label: String, callback: Callable) -> Button:
	var button := Button.new()
	button.text = label
	button.custom_minimum_size = Vector2(400, 54)
	button.pressed.connect(callback)
	return button

## Routes either to a replay room or a scene path.
func _navigate(path: String, replay_level := 0) -> void:
	SfxBus.play_ui(&"click")
	if replay_level > 0:
		GameState.load_level(replay_level)
	else:
		SceneLoader.load_scene(path)
