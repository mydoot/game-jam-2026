class_name ControlsPanel
extends PanelContainer

signal back_requested

func _ready() -> void:
	%Back.pressed.connect(func(): back_requested.emit())

func focus_back() -> void:
	%Back.grab_focus()

