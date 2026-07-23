class_name LevelSelect
extends Control

var selected_index := -1
var cards: Array[Button] = []
var session: GameSessionState

func _ready() -> void:
	session = get_node("/root/GameSession")
	theme = WesternTheme.make()
	%Play.pressed.connect(func(): session.play_level(selected_index))
	%Back.pressed.connect(func(): session.navigate(session.MAIN_MENU_SCENE))
	_refresh_cards()
	_select_level(session.selected_level if session.is_level_unlocked(session.selected_level) else 0)

func _refresh_cards() -> void:
	for child in %Cards.get_children():
		child.queue_free()
	cards.clear()
	var catalog := session.get_catalog()
	for index in catalog.get_level_count():
		var level := catalog.get_level(index)
		var card := Button.new()
		card.custom_minimum_size = Vector2(232, 220)
		card.text = _card_text(index, level)
		card.disabled = not session.is_level_unlocked(index)
		card.pressed.connect(_select_level.bind(index))
		%Cards.add_child(card)
		cards.append(card)

func _card_text(index: int, level: LevelDefinition) -> String:
	if not session.is_level_unlocked(index):
		return "ROOM %02d\n\nLOCKED\nClear Room %02d" % [index + 1, index]
	var mark := "✓ COMPLETE" if session.is_level_completed(index) else "AVAILABLE"
	return "ROOM %02d\n\n%s\n\n%s" % [index + 1, level.title.trim_prefix("Room %d — " % (index + 1)), mark]

func _select_level(index: int) -> void:
	if not session.is_level_unlocked(index):
		return
	selected_index = index
	var level := session.get_catalog().get_level(index)
	%DetailTitle.text = level.title
	%Description.text = level.description
	%Status.text = "COMPLETED" if session.is_level_completed(index) else "NOT YET CLEARED"
	%Status.modulate = WesternTheme.BRASS_BRIGHT if session.is_level_completed(index) else WesternTheme.TEXT
	%Play.disabled = false
	%Play.grab_focus()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		session.navigate(session.MAIN_MENU_SCENE)
		get_viewport().set_input_as_handled()
