class_name LevelCatalog
extends Resource

## Ordered campaign source used by gameplay, progression, menus, and tests.

@export var levels: Array[LevelDefinition] = []

func get_level(index: int) -> LevelDefinition:
	if index < 0 or index >= levels.size():
		return null
	return levels[index]

func get_level_count() -> int:
	return levels.size()

func find_level(level_id: String) -> int:
	for index in levels.size():
		if levels[index].level_id == level_id:
			return index
	return -1

func validate_campaign() -> PackedStringArray:
	var errors := PackedStringArray()
	var ids := {}
	var unlocked := {
		BulletDefinition.Kind.NORMAL: true,
		BulletDefinition.Kind.RICOCHET: true,
		BulletDefinition.Kind.PIERCING: true,
		BulletDefinition.Kind.TERRAIN: false,
		BulletDefinition.Kind.ARMOR_BREAKING: false,
	}
	for index in levels.size():
		var level := levels[index]
		if level == null or not level.is_valid_definition():
			errors.append("Level %d is incomplete." % (index + 1))
			continue
		if ids.has(level.level_id):
			errors.append("Duplicate level id: %s" % level.level_id)
		ids[level.level_id] = true
		for bullet in level.supplied_rounds:
			if bullet != null and not unlocked.get(bullet.kind, false):
				errors.append("%s supplies %s before it unlocks." % [level.level_id, bullet.display_name])
		if level.unlock_reward != null:
			unlocked[level.unlock_reward.kind] = true
	return errors

