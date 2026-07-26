extends Node

## Headless acceptance suite covering catalog, scenes, ammo, and persistence.
var failures: Array[String] = []

## Defers until autoloads and registered classes are ready.
func _ready() -> void:
	call_deferred("_run")

## Exercises all restored campaign contracts.
func _run() -> void:
	_expect(GameState.LEVEL_SCENES.size() == 6, "Campaign does not contain six scenes.")
	var expected := [3, 5, 7, 5, 6, 7]
	for index in range(1, 7):
		var definition = GameState.get_level_definition(index)
		_expect(definition != null and definition.is_valid(), "Level %d definition is invalid." % index)
		_expect(definition.enemies.size() == expected[index - 1], "Level %d enemy count is wrong." % index)
		var packed := load(GameState.LEVEL_SCENES[index - 1]) as PackedScene
		_expect(packed != null, "Level %d scene is missing." % index)
		if packed:
			var level := packed.instantiate() as CampaignLevel
			add_child(level)
			await get_tree().process_frame
			_expect(level.enemies_alive == expected[index - 1], "Level %d did not build correctly." % index)
			level.queue_free()
			await get_tree().process_frame
	for path in [GameState.NORMAL, GameState.PIERCING, GameState.RICOCHET]:
		_expect(load(path) is BasicBullet, "Ammo resource failed: %s" % path)
	for path in [GameState.MAIN_MENU, GameState.LEVEL_SELECT, GameState.SETTINGS, GameState.VICTORY,
			"res://Scenes/UI/pause_menu.tscn", "res://Scenes/Weapons/player_projectile.tscn"]:
		_expect(load(path) is PackedScene, "Scene failed: %s" % path)
	if failures.is_empty():
		print("CAMPAIGN HARDENING TEST PASSED")
		get_tree().quit(0)
	else:
		for failure in failures:
			push_error(failure)
		get_tree().quit(1)

## Records a failure without aborting the remaining checks.
func _expect(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
