extends CanvasLayer

## Process-always pause overlay with embedded settings support.

## Pauses gameplay and builds navigation controls.
func _ready() -> void:
	name = "PauseMenu"
	process_mode = Node.PROCESS_MODE_ALWAYS
	get_tree().paused = true
	var shade := ColorRect.new()
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	shade.color = Color(0.01, 0.015, 0.03, 0.82)
	add_child(shade)
	var box := VBoxContainer.new()
	box.set_anchors_preset(Control.PRESET_CENTER)
	box.position = Vector2(-180, -190)
	box.size = Vector2(360, 380)
	shade.add_child(box)
	var title := Label.new()
	title.text = "PAUSED"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 36)
	box.add_child(title)
	for data in [["RESUME", _resume], ["RESTART", _restart], ["SETTINGS", _settings],
			["LEVEL SELECT", _level_select], ["MAIN MENU", _main_menu]]:
		var button := Button.new()
		button.text = data[0]
		button.pressed.connect(data[1])
		box.add_child(button)

## Resumes and closes on Escape.
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		_resume()

## Returns control to gameplay.
func _resume() -> void:
	get_tree().paused = false
	queue_free()

## Restarts the current campaign room.
func _restart() -> void:
	SfxBus.play_ui(&"click")
	GameState.restart_current_level()

## Opens settings without unpausing the attempt.
func _settings() -> void:
	var settings := load(GameState.SETTINGS).instantiate() as SettingsMenu
	settings.standalone = false
	settings.closed.connect(func(): visible = true)
	visible = false
	get_parent().add_child(settings)

## Returns to level selection.
func _level_select() -> void:
	get_tree().paused = false
	SceneLoader.load_scene(GameState.LEVEL_SELECT)

## Returns to the title screen.
func _main_menu() -> void:
	get_tree().paused = false
	SceneLoader.load_scene(GameState.MAIN_MENU)
