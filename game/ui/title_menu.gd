class_name TitleMenu
extends Control

var session: GameSessionState

func _ready() -> void:
	session = get_node("/root/GameSession")
	theme = WesternTheme.make()
	%Continue.disabled = not session.has_progress()
	%Continue.pressed.connect(func(): session.play_level(session.continue_level()))
	%NewGame.pressed.connect(_on_new_game)
	%LevelSelect.pressed.connect(func(): session.navigate(session.LEVEL_SELECT_SCENE))
	%OptionsButton.pressed.connect(_show_options)
	%ControlsButton.pressed.connect(_show_controls)
	%Quit.pressed.connect(func(): %QuitDialog.popup_centered())
	%Options.back_requested.connect(_close_subpanels)
	%Controls.back_requested.connect(_close_subpanels)
	%ResetDialog.confirmed.connect(_reset_and_start)
	%QuitDialog.confirmed.connect(func(): get_tree().quit())
	%Continue.grab_focus()

func _show_options() -> void:
	%Menu.hide()
	%Controls.hide()
	%Options.show()
	%Options.focus_back()

func _show_controls() -> void:
	%Menu.hide()
	%Options.hide()
	%Controls.show()
	%Controls.focus_back()

func _close_subpanels() -> void:
	%Options.hide()
	%Controls.hide()
	%Menu.show()
	%Continue.grab_focus()

func _on_new_game() -> void:
	if session.has_progress():
		%ResetDialog.popup_centered()
	else:
		_reset_and_start()

func _reset_and_start() -> void:
	session.reset_progress()
	session.play_level(0)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and (%Options.visible or %Controls.visible):
		_close_subpanels()
		get_viewport().set_input_as_handled()
