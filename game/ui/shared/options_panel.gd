class_name OptionsPanel
extends PanelContainer

signal back_requested

@onready var volume: HSlider = %Volume
@onready var mute: CheckButton = %Mute
@onready var fullscreen: CheckButton = %Fullscreen

func _ready() -> void:
	var session := get_node("/root/GameSession")
	volume.value = session.master_volume
	mute.button_pressed = session.master_muted
	fullscreen.button_pressed = session.fullscreen
	volume.value_changed.connect(session.set_master_volume)
	mute.toggled.connect(session.set_master_muted)
	fullscreen.toggled.connect(session.set_fullscreen)
	%Back.pressed.connect(func(): back_requested.emit())

func focus_back() -> void:
	%Back.grab_focus()

