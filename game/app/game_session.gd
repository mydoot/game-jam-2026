class_name GameSessionState
extends Node

signal profile_changed
signal settings_changed

const MAIN_MENU_SCENE := "res://game/ui/title_menu.tscn"
const LEVEL_SELECT_SCENE := "res://game/ui/level_select.tscn"
const WORLD_SCENE := "res://game/game.tscn"
const CATALOG: LevelCatalog = preload("res://game/levels/level_catalog.tres")

var selected_level := 0
var last_played_level := 0
var completed_levels: Array[int] = []
var highest_unlocked_level := 0
var unlocked_bullets := {}
var persistence_enabled := true

var settings := SettingsService.new()
var _store := ProfileStore.new()
var _navigator: SceneNavigator

var master_volume: float:
	get: return settings.master_volume
var master_muted: bool:
	get: return settings.master_muted
var fullscreen: bool:
	get: return settings.fullscreen

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_navigator = SceneNavigator.new()
	add_child(_navigator)
	settings.changed.connect(_on_settings_changed)
	_reset_unlocks()
	load_profile()
	settings.apply()

func get_catalog() -> LevelCatalog:
	return CATALOG

func has_progress() -> bool:
	return not completed_levels.is_empty()

func is_level_unlocked(index: int) -> bool:
	return index >= 0 and index <= highest_unlocked_level and index < CATALOG.get_level_count()

func is_level_completed(index: int) -> bool:
	return completed_levels.has(index)

func is_bullet_unlocked(bullet: BulletDefinition) -> bool:
	return bullet != null and unlocked_bullets.get(bullet.kind, false)

func select_level(index: int) -> bool:
	if not is_level_unlocked(index):
		return false
	selected_level = index
	last_played_level = index
	save_profile()
	return true

func continue_level() -> int:
	if is_level_unlocked(last_played_level) and not is_level_completed(last_played_level):
		return last_played_level
	for index in range(highest_unlocked_level, -1, -1):
		if not is_level_completed(index):
			return index
	return highest_unlocked_level

func complete_level(index: int, reward: BulletDefinition = null) -> void:
	if not completed_levels.has(index):
		completed_levels.append(index)
		completed_levels.sort()
	highest_unlocked_level = mini(CATALOG.get_level_count() - 1, maxi(highest_unlocked_level, index + 1))
	if reward != null:
		unlocked_bullets[reward.kind] = true
	last_played_level = mini(index + 1, CATALOG.get_level_count() - 1)
	save_profile()
	profile_changed.emit()

func reset_progress() -> void:
	selected_level = 0
	last_played_level = 0
	completed_levels.clear()
	highest_unlocked_level = 0
	_reset_unlocks()
	save_profile()
	profile_changed.emit()

func play_level(index: int) -> void:
	if select_level(index):
		navigate(WORLD_SCENE)

func navigate(scene_path: String) -> void:
	_navigator.navigate(scene_path)

func set_master_volume(value: float) -> void:
	settings.set_master_volume(value)

func set_master_muted(value: bool) -> void:
	settings.set_master_muted(value)

func set_fullscreen(value: bool) -> void:
	settings.set_fullscreen(value)

func save_profile() -> void:
	if not persistence_enabled:
		return
	var error := _store.save_profile(_serialize())
	if error != OK:
		push_warning("Could not save profile: %s" % error_string(error))

func load_profile() -> void:
	if not persistence_enabled:
		return
	var data := _store.load_profile(CATALOG.get_level_count())
	selected_level = data.selected_level
	last_played_level = data.last_played_level
	completed_levels.assign(data.completed_levels)
	highest_unlocked_level = data.highest_unlocked_level
	for kind in unlocked_bullets:
		unlocked_bullets[kind] = data.unlocked_bullet_kinds.has(kind)
	for kind in [BulletDefinition.Kind.NORMAL, BulletDefinition.Kind.RICOCHET, BulletDefinition.Kind.PIERCING]:
		unlocked_bullets[kind] = true
	settings.master_volume = data.master_volume
	settings.master_muted = data.master_muted
	settings.fullscreen = data.fullscreen

func _reset_unlocks() -> void:
	unlocked_bullets = {
		BulletDefinition.Kind.NORMAL: true,
		BulletDefinition.Kind.RICOCHET: true,
		BulletDefinition.Kind.PIERCING: true,
		BulletDefinition.Kind.TERRAIN: false,
		BulletDefinition.Kind.ARMOR_BREAKING: false,
	}

func _serialize() -> Dictionary:
	var unlocked_ids: Array[int] = []
	for kind in unlocked_bullets:
		if unlocked_bullets[kind]:
			unlocked_ids.append(kind)
	return {
		"selected_level": selected_level,
		"last_played_level": last_played_level,
		"completed_levels": completed_levels,
		"highest_unlocked_level": highest_unlocked_level,
		"unlocked_bullet_kinds": unlocked_ids,
		"master_volume": settings.master_volume,
		"master_muted": settings.master_muted,
		"fullscreen": settings.fullscreen,
	}

func _on_settings_changed() -> void:
	save_profile()
	settings_changed.emit()
