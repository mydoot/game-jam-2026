class_name ProfileStore
extends RefCounted

## Versioned ConfigFile repository. Invalid values fall back independently.

const SAVE_PATH := "user://profile.cfg"
const SAVE_VERSION := 1

func load_profile(level_count: int) -> Dictionary:
	var result := _defaults()
	var config := ConfigFile.new()
	var error := config.load(SAVE_PATH)
	if error != OK:
		return result
	if int(config.get_value("profile", "version", -1)) != SAVE_VERSION:
		push_warning("Unsupported save version; using a fresh profile.")
		return result
	var completed: Array[int] = []
	for value in config.get_value("profile", "completed_levels", []):
		var index := int(value)
		if index >= 0 and index < level_count and not completed.has(index):
			completed.append(index)
	completed.sort()
	var maximum := maxi(0, level_count - 1)
	var highest := clampi(int(config.get_value("profile", "highest_unlocked_level", 0)), 0, maximum)
	result.completed_levels = completed
	result.highest_unlocked_level = highest
	result.selected_level = clampi(int(config.get_value("profile", "selected_level", 0)), 0, highest)
	result.last_played_level = clampi(int(config.get_value("profile", "last_played_level", 0)), 0, highest)
	result.unlocked_bullet_kinds = config.get_value("profile", "unlocked_bullets", [0, 1, 2])
	result.master_volume = clampf(float(config.get_value("settings", "master_volume", 0.8)), 0.0, 1.0)
	result.master_muted = bool(config.get_value("settings", "master_muted", false))
	result.fullscreen = bool(config.get_value("settings", "fullscreen", false))
	return result

func save_profile(data: Dictionary) -> Error:
	var config := ConfigFile.new()
	config.set_value("profile", "version", SAVE_VERSION)
	config.set_value("profile", "selected_level", data.selected_level)
	config.set_value("profile", "last_played_level", data.last_played_level)
	config.set_value("profile", "completed_levels", data.completed_levels)
	config.set_value("profile", "highest_unlocked_level", data.highest_unlocked_level)
	config.set_value("profile", "unlocked_bullets", data.unlocked_bullet_kinds)
	config.set_value("settings", "master_volume", data.master_volume)
	config.set_value("settings", "master_muted", data.master_muted)
	config.set_value("settings", "fullscreen", data.fullscreen)
	return config.save(SAVE_PATH)

func _defaults() -> Dictionary:
	return {
		"selected_level": 0,
		"last_played_level": 0,
		"completed_levels": [],
		"highest_unlocked_level": 0,
		"unlocked_bullet_kinds": [0, 1, 2],
		"master_volume": 0.8,
		"master_muted": false,
		"fullscreen": false,
	}

