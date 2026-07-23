class_name FailurePanel
extends PanelContainer

signal restart_requested

func _ready() -> void:
	%Restart.pressed.connect(func(): restart_requested.emit())

func present(reason: String) -> void:
	%Message.text = reason
	show()
	%Restart.grab_focus()

