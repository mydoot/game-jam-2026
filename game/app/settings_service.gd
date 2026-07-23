class_name SettingsService
extends RefCounted

signal changed

var master_volume := 0.8
var master_muted := false
var fullscreen := false

func apply() -> void:
	var bus_index := AudioServer.get_bus_index("Master")
	if bus_index >= 0:
		AudioServer.set_bus_mute(bus_index, master_muted)
		AudioServer.set_bus_volume_db(bus_index, linear_to_db(maxf(master_volume, 0.001)))
	if DisplayServer.get_name() != "headless":
		DisplayServer.window_set_mode(
			DisplayServer.WINDOW_MODE_FULLSCREEN if fullscreen
			else DisplayServer.WINDOW_MODE_WINDOWED
		)

func set_master_volume(value: float) -> void:
	master_volume = clampf(value, 0.0, 1.0)
	apply()
	changed.emit()

func set_master_muted(value: bool) -> void:
	master_muted = value
	apply()
	changed.emit()

func set_fullscreen(value: bool) -> void:
	fullscreen = value
	apply()
	changed.emit()

