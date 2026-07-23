extends SceneTree

var failures: Array[String] = []

func _init() -> void:
	call_deferred("_run")

func _expect(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
		push_error("SCENE CONTRACT TEST: " + message)

func _run() -> void:
	var catalog: LevelCatalog = load("res://game/levels/level_catalog.tres")
	_expect(catalog != null, "The campaign catalog must load.")
	_expect(catalog.get_level_count() == 6, "The catalog must order six levels.")
	_expect(catalog.validate_campaign().is_empty(), "Campaign unlock and loadout ordering must be valid.")
	for index in catalog.get_level_count():
		var level := catalog.get_level(index)
		_expect(level.is_valid_definition(), "Level %d must have complete metadata and six rounds." % (index + 1))
		var room := level.room_scene.instantiate() as RoomRoot
		root.add_child(room)
		await process_frame
		_expect(room.get_node_or_null("PlayerSpawn") is Marker2D, "%s needs a PlayerSpawn marker." % level.level_id)
		_expect(room.get_node_or_null("Exit") is ExitDoor, "%s needs an editor-authored exit." % level.level_id)
		_expect(room.get_node_or_null("Enemies") != null, "%s needs an Enemies container." % level.level_id)
		_expect(not room.enemies.get_children().is_empty(), "%s needs at least one authored enemy." % level.level_id)
		for enemy in room.enemies.get_children():
			_expect(enemy.get_node_or_null("CollisionShape2D") != null, "Enemies need a body collision shape.")
			_expect(enemy.get_node_or_null("AttackRange/CollisionShape2D") != null, "Enemies need an attack area.")
			_expect(enemy.collision_layer == 4, "Enemies must use collision layer 4.")
		_expect(room.exit_door.get_node_or_null("Barrier/CollisionShape2D") != null, "The exit needs a visible barrier contract.")
		room.queue_free()
		await process_frame
	_finish("SCENE CONTRACT TESTS")

func _finish(label: String) -> void:
	if failures.is_empty():
		print(label + " PASSED")
		quit(0)
	else:
		print("%s FAILED: %d" % [label, failures.size()])
		quit(1)

