class_name SettingsMenu extends CanvasLayer

## Reusable standalone or pause-embedded display/audio settings screen.
signal closed
@export var standalone := true
var fullscreen_check: CheckButton
var resolution_option: OptionButton
var master_slider: HSlider
var sfx_slider: HSlider

## Builds controls and remains responsive while paused.
func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_build_ui()

## Creates the complete settings form.
func _build_ui() -> void:
	var shade := ColorRect.new()
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	shade.color = Color(0.018, 0.025, 0.04, 0.97)
	add_child(shade)
	var panel := PanelContainer.new()
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.position = Vector2(-300, -310)
	panel.size = Vector2(600, 620)
	shade.add_child(panel)
	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", 12)
	panel.add_child(content)
	var title := Label.new()
	title.text = "SETTINGS"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 38)
	content.add_child(title)
	fullscreen_check = CheckButton.new()
	fullscreen_check.text = "Fullscreen"
	fullscreen_check.button_pressed = GameState.fullscreen
	content.add_child(fullscreen_check)
	content.add_child(_label("Window resolution"))
	resolution_option = OptionButton.new()
	for resolution in GameState.RESOLUTIONS:
		resolution_option.add_item("%d × %d" % [resolution.x, resolution.y])
	resolution_option.select(GameState.resolution_index)
	resolution_option.disabled = fullscreen_check.button_pressed
	fullscreen_check.toggled.connect(func(enabled: bool): resolution_option.disabled = enabled)
	content.add_child(resolution_option)
	content.add_child(_label("Master volume"))
	master_slider = _slider(GameState.master_volume)
	content.add_child(master_slider)
	content.add_child(_label("Sound effects"))
	sfx_slider = _slider(GameState.sfx_volume)
	content.add_child(sfx_slider)
	var controls := Label.new()
	controls.text = "CONTROLS\nWASD  Move     MOUSE  Aim\nLEFT CLICK  Fire     E  Planning panel\nESC  Pause / Back"
	controls.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	content.add_child(controls)
	var apply := Button.new()
	apply.text = "APPLY"
	apply.pressed.connect(_apply)
	content.add_child(apply)
	var back := Button.new()
	back.text = "BACK"
	back.pressed.connect(_close)
	content.add_child(back)

## Creates a compact section label.
func _label(text: String) -> Label:
	var label := Label.new()
	label.text = text
	return label

## Creates a percentage audio slider.
func _slider(value: float) -> HSlider:
	var slider := HSlider.new()
	slider.max_value = 100
	slider.value = value
	return slider

## Commits, applies, and saves staged values.
func _apply() -> void:
	GameState.fullscreen = fullscreen_check.button_pressed
	GameState.resolution_index = resolution_option.selected
	GameState.master_volume = master_slider.value
	GameState.sfx_volume = sfx_slider.value
	GameState.apply_settings()
	GameState.save()
	SfxBus.play_ui(&"click")

## Returns to main menu or closes the embedded screen.
func _close() -> void:
	SfxBus.play_ui(&"click")
	if standalone:
		SceneLoader.load_scene(GameState.MAIN_MENU)
	else:
		closed.emit()
		queue_free()
