class_name PauseMenu
extends CanvasLayer

signal restart_requested

var _leave_target := ""
var session: GameSessionState

func _ready() -> void:
	session = get_node("/root/GameSession")
	$Panel.theme = WesternTheme.make()
	process_mode = Node.PROCESS_MODE_ALWAYS
	%Resume.pressed.connect(close)
	%Restart.pressed.connect(_restart)
	%OptionsButton.pressed.connect(_show_options)
	%ControlsButton.pressed.connect(_show_controls)
	%LevelSelect.pressed.connect(func(): _ask_leave(session.LEVEL_SELECT_SCENE))
	%MainMenu.pressed.connect(func(): _ask_leave(session.MAIN_MENU_SCENE))
	%Options.back_requested.connect(_show_main)
	%Controls.back_requested.connect(_show_main)
	%LeaveDialog.confirmed.connect(_confirm_navigation)
	hide()

func open() -> void:
	if visible:
		return
	show()
	get_tree().paused = true
	_show_main()
	%Resume.grab_focus()

func close() -> void:
	hide()
	get_tree().paused = false

func _show_main() -> void:
	%Main.show()
	%Options.hide()
	%Controls.hide()
	%Resume.grab_focus()

func _show_options() -> void:
	%Main.hide()
	%Options.show()
	%Options.focus_back()

func _show_controls() -> void:
	%Main.hide()
	%Controls.show()
	%Controls.focus_back()

func _restart() -> void:
	close()
	restart_requested.emit()

func _ask_leave(target: String) -> void:
	_leave_target = target
	%LeaveDialog.popup_centered()

func _confirm_navigation() -> void:
	close()
	session.navigate(_leave_target)

func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	if event.is_action_pressed("ui_cancel") or (
		event is InputEventJoypadButton and event.pressed and event.button_index == JOY_BUTTON_START
	):
		if %Options.visible or %Controls.visible:
			_show_main()
		else:
			close()
		get_viewport().set_input_as_handled()
