extends Control

## Campaign room grid backed by GameState unlocks, completions, and best times.

## Builds six level cards and a main-menu return action.
func _ready() -> void:
	var background := ColorRect.new()
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	background.color = Color(0.025, 0.032, 0.055)
	add_child(background)
	var panel := PanelContainer.new()
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.position = Vector2(-470, -310)
	panel.size = Vector2(940, 620)
	add_child(panel)
	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", 18)
	panel.add_child(content)
	var title := Label.new()
	title.text = "CHOOSE A CHAMBER"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 38)
	content.add_child(title)
	var grid := GridContainer.new()
	grid.columns = 3
	grid.add_theme_constant_override("h_separation", 16)
	grid.add_theme_constant_override("v_separation", 16)
	content.add_child(grid)
	for level_index in range(1, GameState.LEVEL_COUNT + 1):
		var definition = GameState.get_level_definition(level_index)
		var button := Button.new()
		var state := "LOCKED"
		if GameState.completed_levels.has(level_index):
			state = "CLEARED"
		elif GameState.is_level_unlocked(level_index):
			state = "READY"
		var best := ""
		if GameState.best_times.has(str(level_index)):
			best = "\nBEST %.1fs" % float(GameState.best_times[str(level_index)])
		button.text = "%02d\n%s\n%s%s" % [level_index, definition.title, state, best]
		button.custom_minimum_size = Vector2(280, 170)
		button.disabled = not GameState.is_level_unlocked(level_index)
		button.pressed.connect(_choose_level.bind(level_index))
		grid.add_child(button)
	var back := Button.new()
	back.text = "BACK TO MENU"
	back.pressed.connect(func(): SfxBus.play_ui(&"click"); SceneLoader.load_scene(GameState.MAIN_MENU))
	content.add_child(back)

## Starts a selected unlocked room.
func _choose_level(level_index: int) -> void:
	SfxBus.play_ui(&"click")
	GameState.load_level(level_index)
