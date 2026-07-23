class_name PlanningPanel
extends PanelContainer

signal start_requested(rounds: Array[BulletDefinition])

@export var round_button_scene: PackedScene

var supply: Array[BulletDefinition] = []
var slots: Array[BulletDefinition] = []
var _selection_container := ""
var _selection_index := -1

func _ready() -> void:
	%Start.pressed.connect(_emit_start)

func setup(level: LevelDefinition) -> void:
	supply = level.supplied_rounds.duplicate()
	slots.assign([null, null, null, null, null, null])
	_selection_container = ""
	%Title.text = level.title
	%Tutorial.text = level.tutorial + "\nDrag rounds, or click a round then a slot. Click a loaded round twice to unload it."
	_rebuild()
	show()

func _rebuild() -> void:
	for row in [%Supply, %Slots]:
		for child in row.get_children():
			child.queue_free()
	for index in supply.size():
		%Supply.add_child(_button("supply", index, supply[index]))
	for index in 6:
		var definition: BulletDefinition = slots[index]
		var button := _button("slot", index, definition)
		if definition == null:
			button.text = "%d. EMPTY" % (index + 1)
			button.modulate = Color("8a929e")
		%Slots.add_child(button)
	var ready := supply.is_empty() and not slots.has(null)
	%Start.disabled = not ready
	%Start.text = "BEGIN ROOM" if ready else "LOAD ALL 6 ROUNDS"

func _button(container: String, index: int, definition: BulletDefinition) -> RoundSlotButton:
	var button := round_button_scene.instantiate() as RoundSlotButton
	button.container_name = container
	button.slot_index = index
	button.has_round = definition != null
	if definition != null:
		button.text = definition.display_name
		button.modulate = definition.color
	button.pressed.connect(_on_round_clicked.bind(container, index))
	button.round_dropped.connect(_move_or_swap)
	return button

func _on_round_clicked(container: String, index: int) -> void:
	if _selection_container.is_empty():
		if _get_round(container, index) == null:
			return
		_selection_container = container
		_selection_index = index
		return
	if _selection_container == container and _selection_index == index:
		if container == "slot":
			supply.append(slots[index])
			slots[index] = null
			_selection_container = ""
			_rebuild()
		return
	_move_or_swap(_selection_container, _selection_index, container, index)

func _move_or_swap(from_container: String, from_index: int, to_container: String, to_index: int) -> void:
	var source := _get_round(from_container, from_index)
	if source == null:
		_selection_container = ""
		return
	var destination := _get_round(to_container, to_index)
	if from_container == "supply" and to_container == "slot":
		supply.remove_at(from_index)
		slots[to_index] = source
		if destination != null:
			supply.append(destination)
	elif from_container == "slot" and to_container == "slot":
		slots[from_index] = destination
		slots[to_index] = source
	elif from_container == "slot" and to_container == "supply":
		slots[from_index] = destination
		supply[to_index] = source
	elif from_container == "supply" and to_container == "supply":
		supply[from_index] = destination
		supply[to_index] = source
	_selection_container = ""
	_rebuild()

func _get_round(container: String, index: int) -> BulletDefinition:
	if container == "supply" and index >= 0 and index < supply.size():
		return supply[index]
	if container == "slot" and index >= 0 and index < slots.size():
		return slots[index]
	return null

func _emit_start() -> void:
	if %Start.disabled:
		return
	start_requested.emit(slots.duplicate())

