extends Node

## Persistent campaign/settings service and typed six-room catalog.
const SAVE_PATH := "user://save.cfg"
const SAVE_VERSION := 2
const LEVEL_COUNT := 6
const MAIN_MENU := "res://Scenes/Main Menu/main_menu.tscn"
const LEVEL_SELECT := "res://Scenes/UI/level_select.tscn"
const SETTINGS := "res://Scenes/UI/settings_menu.tscn"
const VICTORY := "res://Scenes/UI/victory.tscn"
const LEVEL_SCENES := [
	"res://Scenes/Levels/level_01.tscn", "res://Scenes/Levels/level_02.tscn",
	"res://Scenes/Levels/level_03.tscn", "res://Scenes/Levels/level_04.tscn",
	"res://Scenes/Levels/level_05.tscn", "res://Scenes/Levels/level_06.tscn",
]
const RESOLUTIONS := [Vector2i(1280, 720), Vector2i(1600, 900), Vector2i(1920, 1080)]
const NORMAL := "res://_Scripts/Resources/basic_bullet.tres"
const PIERCING := "res://_Scripts/Resources/piercing_bullet.tres"
const RICOCHET := "res://_Scripts/Resources/ricochet_bullet.tres"
const LEVEL_DEFINITION_SCRIPT := preload("res://_Scripts/Resources/LevelDefinition.gd")
const SENTRY_PLACEMENT_SCRIPT := preload("res://_Scripts/Resources/SentryPlacement.gd")

var highest_unlocked_level := 1
var completed_levels: Array[int] = []
var best_times: Dictionary = {}
var current_level := 1
var fullscreen := false
var resolution_index := 0
var master_volume := 80.0
var sfx_volume := 85.0
var save_path := SAVE_PATH
var _catalog: Array[Resource] = []

## Builds the catalog, restores persistence, and applies settings.
func _ready() -> void:
	_catalog = _build_catalog()
	load_save()
	apply_settings()

## Returns one clamped authored level definition.
func get_level_definition(level_index: int) -> Resource:
	if _catalog.is_empty():
		_catalog = _build_catalog()
	return _catalog[clampi(level_index, 1, LEVEL_COUNT) - 1]

## Compatibility accessor retained for older callers.
func get_level_data(level_index: int) -> Resource:
	return get_level_definition(level_index)

## Resolves exactly six ammo resources for a level.
func get_level_bullets(level_index: int) -> Array[Resource]:
	var result: Array[Resource] = []
	for path in get_level_definition(level_index).bullet_paths:
		var bullet := load(path)
		if bullet:
			result.append(bullet)
	return result

## Reports whether a level-select card can be activated.
func is_level_unlocked(level_index: int) -> bool:
	return level_index >= 1 and level_index <= highest_unlocked_level

## Records completion, best time, and next-level access.
func complete_level(level_index: int, completion_time: float) -> void:
	level_index = clampi(level_index, 1, LEVEL_COUNT)
	if not completed_levels.has(level_index):
		completed_levels.append(level_index)
		completed_levels.sort()
	var key := str(level_index)
	if completion_time >= 0.0 and (not best_times.has(key) or completion_time < float(best_times[key])):
		best_times[key] = completion_time
	highest_unlocked_level = maxi(highest_unlocked_level, mini(level_index + 1, LEVEL_COUNT))
	save()

## Starts an unlocked campaign room.
func load_level(level_index: int) -> bool:
	if not is_level_unlocked(level_index):
		return false
	current_level = clampi(level_index, 1, LEVEL_COUNT)
	get_tree().paused = false
	return SceneLoader.load_scene(LEVEL_SCENES[current_level - 1])

## Reloads the current room from preview state.
func restart_current_level() -> bool:
	return load_level(current_level)

## Applies validated display and audio options.
func apply_settings() -> void:
	resolution_index = clampi(resolution_index, 0, RESOLUTIONS.size() - 1)
	master_volume = clampf(master_volume, 0.0, 100.0)
	sfx_volume = clampf(sfx_volume, 0.0, 100.0)
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN if fullscreen else DisplayServer.WINDOW_MODE_WINDOWED)
	if not fullscreen:
		DisplayServer.window_set_size(RESOLUTIONS[resolution_index])
		if DisplayServer.get_name() != "headless":
			var screen_size := DisplayServer.screen_get_size(DisplayServer.window_get_current_screen())
			DisplayServer.window_set_position((screen_size - RESOLUTIONS[resolution_index]) / 2)
	_set_bus_volume("Master", master_volume)
	_set_bus_volume("SFX", sfx_volume)

## Writes schema-v2 campaign and settings data.
func save() -> bool:
	var config := ConfigFile.new()
	config.set_value("meta", "version", SAVE_VERSION)
	config.set_value("campaign", "highest_unlocked", highest_unlocked_level)
	config.set_value("campaign", "completed", completed_levels)
	config.set_value("campaign", "best_times", best_times)
	config.set_value("settings", "fullscreen", fullscreen)
	config.set_value("settings", "resolution_index", resolution_index)
	config.set_value("settings", "master_volume", master_volume)
	config.set_value("settings", "sfx_volume", sfx_volume)
	var error := config.save(save_path)
	if error != OK:
		push_warning("Could not save progress: %s" % error_string(error))
		return false
	return true

## Loads and independently sanitizes every persisted field.
func load_save() -> void:
	var config := ConfigFile.new()
	if config.load(save_path) != OK:
		return
	var unlocked = config.get_value("campaign", "highest_unlocked", 1)
	if unlocked is int or unlocked is float:
		highest_unlocked_level = clampi(int(unlocked), 1, LEVEL_COUNT)
	var completed = config.get_value("campaign", "completed", [])
	if completed is Array:
		completed_levels.clear()
		for value in completed:
			if (value is int or value is float) and int(value) in range(1, LEVEL_COUNT + 1) and not completed_levels.has(int(value)):
				completed_levels.append(int(value))
		completed_levels.sort()
	var times = config.get_value("campaign", "best_times", {})
	if times is Dictionary:
		best_times.clear()
		for key in times:
			var level_index := int(str(key))
			var value = times[key]
			if level_index in range(1, LEVEL_COUNT + 1) and (value is int or value is float) and float(value) >= 0.0:
				best_times[str(level_index)] = float(value)
	var loaded_fullscreen = config.get_value("settings", "fullscreen", false)
	if loaded_fullscreen is bool:
		fullscreen = loaded_fullscreen
	var loaded_resolution = config.get_value("settings", "resolution_index", 0)
	if loaded_resolution is int or loaded_resolution is float:
		resolution_index = clampi(int(loaded_resolution), 0, RESOLUTIONS.size() - 1)
	var loaded_master = config.get_value("settings", "master_volume", 80.0)
	if loaded_master is int or loaded_master is float:
		master_volume = clampf(float(loaded_master), 0.0, 100.0)
	var loaded_sfx = config.get_value("settings", "sfx_volume", master_volume)
	if loaded_sfx is int or loaded_sfx is float:
		sfx_volume = clampf(float(loaded_sfx), 0.0, 100.0)

## Converts a percentage into one Godot audio-bus level.
func _set_bus_volume(bus_name: String, value: float) -> void:
	var bus := AudioServer.get_bus_index(bus_name)
	if bus < 0:
		return
	AudioServer.set_bus_mute(bus, value <= 0.0)
	AudioServer.set_bus_volume_db(bus, linear_to_db(value / 100.0) if value > 0.0 else -80.0)

## Creates one compact sentry placement.
func _sentry(x: int, y: int, facing: float, sight: float, delay: float, shielded := false) -> Resource:
	return SENTRY_PLACEMENT_SCRIPT.new().setup(Vector2i(x, y), facing, sight, delay, shielded)

## Creates one typed campaign definition.
func _level(index: int, title: String, brief: String, spawn: Vector2i, exit: Vector2i,
		bullets: Array[String], walls: Array[Rect2i], enemies: Array[Resource],
		minimum_shots: int) -> Resource:
	var definition := LEVEL_DEFINITION_SCRIPT.new()
	definition.index = index
	definition.title = title
	definition.brief = brief
	definition.spawn = spawn
	definition.exit = exit
	definition.bullet_paths = bullets
	definition.walls = walls
	definition.enemies = enemies
	definition.minimum_solution_shots = minimum_shots
	return definition

## Builds six forgiving mechanic-focused authored rooms.
func _build_catalog() -> Array[Resource]:
	return [
		_level(1, "FIRST CHAMBER", "Read the room, load the cylinder, clear the sentries.", Vector2i(3,18), Vector2i(36,3),
			[NORMAL,NORMAL,NORMAL,NORMAL,NORMAL,NORMAL], [Rect2i(11,5,2,11),Rect2i(25,6,2,10)],
			[_sentry(18,17,180,300,1.8),_sentry(21,6,140,280,1.9),_sentry(33,13,200,290,1.8)], 3),
		_level(2, "CROSSFIRE", "Move cover to cover; red sight means a shot is charging.", Vector2i(3,18), Vector2i(36,3),
			[NORMAL,NORMAL,NORMAL,NORMAL,NORMAL,NORMAL], [Rect2i(9,4,2,10),Rect2i(18,10,3,8),Rect2i(29,3,2,10),Rect2i(30,16,5,2)],
			[_sentry(13,17,180,290,1.6),_sentry(16,5,130,300,1.8),_sentry(24,7,150,320,1.7),_sentry(27,18,210,300,1.55),_sentry(35,11,180,280,1.65)], 5),
		_level(3, "STRAIGHT THROUGH", "Line up pairs. Piercing rounds pass through every sentry.", Vector2i(3,18), Vector2i(36,3),
			[PIERCING,PIERCING,NORMAL,NORMAL,NORMAL,NORMAL], [Rect2i(10,3,2,6),Rect2i(10,12,2,7),Rect2i(27,8,2,8)],
			[_sentry(16,6,180,280,1.75),_sentry(21,6,180,280,1.85),_sentry(16,14,180,280,1.75),_sentry(21,14,180,280,1.85),_sentry(32,4,150,270,1.7),_sentry(33,11,180,270,1.65),_sentry(33,18,210,270,1.6)], 5),
		_level(4, "BANK SHOT", "Blue-shielded sentries only break after a wall bounce.", Vector2i(3,18), Vector2i(36,3),
			[RICOCHET,RICOCHET,NORMAL,NORMAL,NORMAL,NORMAL], [Rect2i(12,5,2,12),Rect2i(24,4,10,2),Rect2i(24,4,2,10),Rect2i(33,4,2,10)],
			[_sentry(29,9,180,250,1.9,true),_sentry(18,17,180,290,1.7),_sentry(20,5,150,280,1.8),_sentry(29,17,190,280,1.65),_sentry(36,17,210,270,1.65)], 5),
		_level(5, "LOADED CHOICE", "Route around the room in the same order as your cylinder.", Vector2i(3,18), Vector2i(36,3),
			[NORMAL,NORMAL,PIERCING,PIERCING,RICOCHET,RICOCHET], [Rect2i(10,3,2,11),Rect2i(22,9,2,10),Rect2i(29,4,7,2),Rect2i(29,4,2,8)],
			[_sentry(16,7,180,280,1.65),_sentry(21,7,180,280,1.75),_sentry(33,9,180,240,1.85,true),_sentry(16,17,180,285,1.6),_sentry(27,17,190,280,1.55),_sentry(36,17,210,270,1.55)], 5),
		_level(6, "DEADEYE", "Two lines, one bank, two exposed. One round remains for recovery.", Vector2i(3,18), Vector2i(37,3),
			[NORMAL,NORMAL,PIERCING,PIERCING,RICOCHET,RICOCHET], [Rect2i(9,3,2,12),Rect2i(22,8,2,11),Rect2i(29,3,8,2),Rect2i(29,3,2,10)],
			[_sentry(15,6,180,285,1.5),_sentry(20,6,180,285,1.6),_sentry(15,14,180,285,1.5),_sentry(20,14,180,285,1.6),_sentry(34,8,180,235,1.7,true),_sentry(31,17,190,260,1.45),_sentry(36,18,220,260,1.45)], 5),
	]
