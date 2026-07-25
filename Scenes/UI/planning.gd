class_name PlanningUI extends CanvasLayer

## Preview-phase loadout editor. Players click available rounds to append them
## to the revolver and click chambered rounds to return them.
signal start_requested(ordered_bullets: Array[Resource])

var available_bullets: Array[Resource] = []
var selected_indices: Array[int] = []
var panel: PanelContainer
var available_row: HBoxContainer
var chamber_row: HBoxContainer
var start_button: Button
var hint_label: Label
var description_label: Label
var _panel_visible := true

## Builds the responsive planning interface after CampaignLevel supplies bullets.
func _ready() -> void:
	_build_ui()
	_rebuild()

## Toggles the loadout panel with E so the full room remains inspectable.
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("hide_menu"):
		_panel_visible = not _panel_visible
		panel.visible = _panel_visible
		hint_label.text = "[E] Hide loadout" if _panel_visible else "[E] Show loadout"
		get_viewport().set_input_as_handled()

## Constructs labels, bullet rows, and the begin button without fragile paths.
func _build_ui() -> void:
	hint_label = Label.new()
	hint_label.text = "[E] Hide loadout"
	hint_label.position = Vector2(18, 16)
	hint_label.add_theme_font_size_override("font_size", 20)
	add_child(hint_label)

	panel = PanelContainer.new()
	panel.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	panel.position = Vector2(-470, -285)
	panel.size = Vector2(940, 260)
	add_child(panel)
	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", 8)
	panel.add_child(content)
	var title := Label.new()
	title.text = "PLAN THE CHAMBER"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 27)
	content.add_child(title)
	var instructions := Label.new()
	instructions.text = "Click available rounds in the order you want to fire them. Click a chamber to undo."
	instructions.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	content.add_child(instructions)
	available_row = HBoxContainer.new()
	available_row.alignment = BoxContainer.ALIGNMENT_CENTER
	content.add_child(available_row)
	var chamber_title := Label.new()
	chamber_title.text = "CYLINDER — FIRST SHOT ON THE LEFT"
	chamber_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	content.add_child(chamber_title)
	chamber_row = HBoxContainer.new()
	chamber_row.alignment = BoxContainer.ALIGNMENT_CENTER
	content.add_child(chamber_row)
	description_label = Label.new()
	description_label.text = "Select a round to inspect it."
	description_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	description_label.add_theme_color_override("font_color", Color(0.65, 0.78, 0.9))
	content.add_child(description_label)
	start_button = Button.new()
	start_button.text = "BEGIN LEVEL"
	start_button.custom_minimum_size = Vector2(220, 42)
	start_button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	start_button.pressed.connect(_on_start_pressed)
	content.add_child(start_button)

## Rebuilds both rows so duplicate bullet resources remain independently usable.
func _rebuild() -> void:
	if available_row == null:
		return
	for child in available_row.get_children():
		available_row.remove_child(child)
		child.queue_free()
	for child in chamber_row.get_children():
		chamber_row.remove_child(child)
		child.queue_free()
	for index in available_bullets.size():
		var bullet := available_bullets[index] as BasicBullet
		var button := _bullet_button(bullet, "%d" % (index + 1))
		button.disabled = selected_indices.has(index)
		button.pressed.connect(_select_bullet.bind(index))
		button.mouse_entered.connect(_describe.bind(bullet))
		available_row.add_child(button)
	for chamber in 6:
		if chamber < selected_indices.size():
			var bullet := available_bullets[selected_indices[chamber]] as BasicBullet
			var button := _bullet_button(bullet, "%d" % (chamber + 1))
			button.pressed.connect(_remove_chamber.bind(chamber))
			button.mouse_entered.connect(_describe.bind(bullet))
			chamber_row.add_child(button)
		else:
			var empty := Button.new()
			empty.text = "%d\nEMPTY" % (chamber + 1)
			empty.disabled = true
			empty.custom_minimum_size = Vector2(118, 48)
			chamber_row.add_child(empty)
	start_button.disabled = selected_indices.size() != 6

## Produces a readable button with icon, type name, and sequence number.
func _bullet_button(bullet: BasicBullet, number: String) -> Button:
	var button := Button.new()
	button.text = "%s\n%s" % [number, bullet.display_name.to_upper()]
	button.icon = bullet.get_icon()
	button.expand_icon = true
	button.add_theme_constant_override("icon_max_width", 28)
	button.custom_minimum_size = Vector2(118, 48)
	button.tooltip_text = "%s round" % bullet.display_name
	var color := _bullet_color(bullet.bullet_type)
	button.add_theme_color_override("font_color", color)
	button.add_theme_color_override("font_hover_color", color.lightened(0.2))
	return button

## Appends one unused supplied round to the firing order.
func _select_bullet(index: int) -> void:
	if selected_indices.size() < 6 and not selected_indices.has(index):
		SfxBus.play_ui(&"click")
		selected_indices.append(index)
		_rebuild()

## Returns the selected chamber to the available row.
func _remove_chamber(chamber: int) -> void:
	if chamber >= 0 and chamber < selected_indices.size():
		SfxBus.play_ui(&"click")
		selected_indices.remove_at(chamber)
		_rebuild()

## Emits the six concrete resources in their selected order.
func _on_start_pressed() -> void:
	if selected_indices.size() != 6:
		return
	var ordered: Array[Resource] = []
	for index in selected_indices:
		ordered.append(available_bullets[index])
	start_button.disabled = true
	SfxBus.play_ui(&"click")
	start_requested.emit(ordered)

## Shows the hovered bullet's concise mechanical description.
func _describe(bullet: BasicBullet) -> void:
	description_label.text = "%s — %s" % [bullet.display_name.to_upper(), bullet.description]

## Returns the shared gameplay color for one ammunition family.
func _bullet_color(bullet_type: BasicBullet.BulletType) -> Color:
	match bullet_type:
		BasicBullet.BulletType.PIERCING:
			return Color(1.0, 0.45, 0.68)
		BasicBullet.BulletType.RICOCHET:
			return Color(0.35, 0.9, 1.0)
	return Color(1.0, 0.78, 0.3)
