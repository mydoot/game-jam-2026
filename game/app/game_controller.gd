class_name GameController
extends Node2D

enum State { PLANNING, PLAYING, EXIT_UNLOCKED, FAILED, COMPLETE }

@onready var room_controller: RoomController = $RoomController
@onready var room_container: Node2D = $RoomContainer
@onready var hud: GameHUD = $GameHUD
@onready var pause_menu: PauseMenu = $PauseMenu

var state := State.PLANNING
var level: LevelDefinition
var session: GameSessionState
var transition_locked := false

func _ready() -> void:
	session = get_node("/root/GameSession")
	hud.start_requested.connect(_start_level)
	hud.restart_requested.connect(restart_level)
	hud.completion_action_requested.connect(_on_completion_action)
	pause_menu.restart_requested.connect(restart_level)
	room_controller.room_started.connect(func(): state = State.PLAYING)
	room_controller.enemy_count_changed.connect(hud.update_enemy_count)
	room_controller.room_cleared.connect(_on_room_cleared)
	room_controller.room_failed.connect(_on_room_failed)
	room_controller.exit_entered.connect(_on_exit_entered)
	load_selected_level()

func load_selected_level() -> void:
	state = State.PLANNING
	transition_locked = false
	level = session.get_catalog().get_level(session.selected_level)
	assert(level != null, "Selected campaign level must exist.")
	for child in room_container.get_children():
		child.queue_free()
	var room := level.room_scene.instantiate() as RoomRoot
	room_container.add_child(room)
	room_controller.setup(room)
	room_controller.player.health_changed.connect(hud.update_health)
	room_controller.player.cylinder_changed.connect(hud.update_cylinder)
	hud.setup(level, room_controller.player.health, room_controller.player.max_health, room_controller.enemies_alive)

func restart_level() -> void:
	get_tree().paused = false
	session.navigate(session.WORLD_SCENE)

func _start_level(rounds: Array[BulletDefinition]) -> void:
	if room_controller.start(rounds):
		hud.show_combat()

func _on_room_cleared() -> void:
	state = State.EXIT_UNLOCKED
	hud.show_clear()

func _on_room_failed(reason: String) -> void:
	state = State.FAILED
	hud.show_failure(reason)

func _on_exit_entered() -> void:
	if state != State.EXIT_UNLOCKED or transition_locked:
		return
	transition_locked = true
	var index := session.selected_level
	session.complete_level(index, level.unlock_reward)
	state = State.COMPLETE
	room_controller.mark_complete()
	hud.show_level_complete(index, level.unlock_reward, index == session.get_catalog().get_level_count() - 1)

func _on_completion_action(action: CompletionPanel.Action) -> void:
	match action:
		CompletionPanel.Action.NEXT_LEVEL:
			session.play_level(mini(session.selected_level + 1, session.get_catalog().get_level_count() - 1))
		CompletionPanel.Action.REPLAY:
			session.navigate(session.WORLD_SCENE)
		CompletionPanel.Action.LEVEL_SELECT:
			session.navigate(session.LEVEL_SELECT_SCENE)
		CompletionPanel.Action.MAIN_MENU:
			session.navigate(session.MAIN_MENU_SCENE)

func _unhandled_input(event: InputEvent) -> void:
	if state == State.FAILED and event is InputEventKey and event.pressed and event.keycode == KEY_R:
		restart_level()
	elif _is_pause_event(event) and state in [State.PLANNING, State.PLAYING, State.EXIT_UNLOCKED]:
		if not pause_menu.visible:
			pause_menu.open()
			get_viewport().set_input_as_handled()

func _is_pause_event(event: InputEvent) -> bool:
	return event.is_action_pressed("ui_cancel") or (
		event is InputEventJoypadButton and event.pressed and event.button_index == JOY_BUTTON_START
	)
