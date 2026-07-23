extends SceneTree

var failures: Array[String] = []

func _init() -> void:
	call_deferred("_run")

func _expect(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
		push_error("FRONTEND TEST: " + message)

func _run() -> void:
	var session: GameSessionState = root.get_node("GameSession")
	session.persistence_enabled = false
	session.reset_progress()
	_expect(session.highest_unlocked_level == 0, "Fresh profiles unlock only room 1.")
	_expect(not session.has_progress(), "Fresh profiles do not enable Continue.")
	_expect(session.is_level_unlocked(0), "Room 1 is always selectable.")
	_expect(not session.is_level_unlocked(1), "Room 2 begins locked.")

	var title := (load("res://game/ui/title_menu.tscn") as PackedScene).instantiate() as TitleMenu
	root.add_child(title)
	await process_frame
	_expect(title.get_node("%Continue").disabled, "Continue must be disabled without progress.")
	title.queue_free()
	await process_frame

	var select := (load("res://game/ui/level_select.tscn") as PackedScene).instantiate() as LevelSelect
	root.add_child(select)
	await process_frame
	_expect(select.cards.size() == 6, "Level select must display six catalog cards.")
	_expect(not select.cards[0].disabled, "Room 1 card must be enabled.")
	_expect(select.cards[1].disabled, "Locked room cards must be disabled.")
	select.queue_free()
	await process_frame

	session.complete_level(0)
	_expect(session.is_level_completed(0), "Completing a level records completion.")
	_expect(session.is_level_unlocked(1), "Completing a level unlocks the next.")
	var terrain: BulletDefinition = load("res://game/bullets/resources/terrain_altering.tres")
	session.complete_level(2, terrain)
	_expect(session.is_bullet_unlocked(terrain), "Catalog rewards unlock their bullet resource kind.")

	var pause := (load("res://game/ui/pause_menu.tscn") as PackedScene).instantiate() as PauseMenu
	root.add_child(pause)
	await process_frame
	pause.open()
	_expect(paused and pause.visible, "Opening pause freezes the tree and shows the menu.")
	pause.close()
	_expect(not paused and not pause.visible, "Closing pause resumes the tree.")
	pause.queue_free()
	_finish()

func _finish() -> void:
	if failures.is_empty():
		print("FRONTEND TESTS PASSED")
		quit(0)
	else:
		print("FRONTEND TESTS FAILED: %d" % failures.size())
		quit(1)
