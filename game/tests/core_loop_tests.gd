extends SceneTree

var failures: Array[String] = []

func _init() -> void:
	call_deferred("_run")

func _expect(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
		push_error("CORE LOOP TEST: " + message)

func _run() -> void:
	var session: GameSessionState = root.get_node("GameSession")
	session.persistence_enabled = false
	session.reset_progress()
	var game_scene: PackedScene = load("res://game/game.tscn")
	_expect(game_scene != null, "The gameplay scene must load.")
	var game := game_scene.instantiate() as GameController
	root.add_child(game)
	await process_frame
	await process_frame
	_expect(game.state == GameController.State.PLANNING, "A level must begin in planning.")
	_expect(game.room_controller.enemies_alive == 2, "Room 1 must instantiate its authored enemies.")
	_expect(not game.room_controller.exit_door.unlocked, "The exit must begin locked.")
	_expect(game.hud.planning.supply.size() == 6, "Planning must receive six resource-backed rounds.")
	_expect(game.hud.planning.slots.has(null), "The cylinder must begin empty.")

	var level := session.get_catalog().get_level(0)
	game._start_level(level.supplied_rounds)
	_expect(game.state == GameController.State.PLAYING, "Six supplied rounds must start combat.")
	_expect(game.room_controller.player.cylinder.size() == 6, "The player must receive the ordered cylinder.")
	var before := game.room_controller.player.cylinder.size()
	game.room_controller.player.set_shooting_enabled(false)
	game.room_controller.player.shoot()
	_expect(game.room_controller.player.cylinder.size() == before, "Shooting lock must preserve the cylinder.")

	var enemy_scene: PackedScene = load("res://game/enemies/enemy.tscn")
	var armored := enemy_scene.instantiate() as SightEnemy
	armored.armored = true
	game.room_controller.room.add_child(armored)
	var normal: BulletDefinition = load("res://game/bullets/resources/normal.tres")
	var breaker: BulletDefinition = load("res://game/bullets/resources/armor_breaking.tres")
	_expect(not armored.receive_bullet(normal), "Normal rounds must not defeat armored enemies.")
	_expect(armored.receive_bullet(breaker), "Armor breakers must defeat armored enemies.")

	var contact_enemy := enemy_scene.instantiate() as SightEnemy
	contact_enemy.position = game.room_controller.player.position + Vector2(30, 0)
	contact_enemy.set_player(game.room_controller.player)
	game.room_controller.room.add_child(contact_enemy)
	contact_enemy.alerted = true
	contact_enemy.activate()
	var health_before := game.room_controller.player.health
	for _frame in 8:
		await physics_frame
	_expect(game.room_controller.player.health < health_before, "Collider contact must damage the player.")
	contact_enemy.queue_free()

	var cracked_scene: PackedScene = load("res://game/environment/cracked_wall.tscn")
	var cracked := cracked_scene.instantiate() as DestructibleWall
	cracked.position = Vector2(-400, -500)
	cracked.size = Vector2(40, 40)
	game.room_controller.room.add_child(cracked)
	var terrain_destroyed := [false]
	cracked.destroyed.connect(func(_wall: DestructibleWall): terrain_destroyed[0] = true)
	var projectile_scene: PackedScene = load("res://game/bullets/projectile.tscn")
	var terrain_projectile := projectile_scene.instantiate() as TacticalProjectile
	game.room_controller.room.add_child(terrain_projectile)
	terrain_projectile.configure(
		load("res://game/bullets/resources/terrain_altering.tres"),
		Vector2(-500, -500),
		Vector2.RIGHT
	)
	for _frame in 20:
		await physics_frame
	_expect(terrain_destroyed[0], "Terrain rounds must destroy cracked walls.")

	var pierce_hits := [0]
	for enemy_x in [-400.0, -300.0]:
		var aligned := enemy_scene.instantiate() as SightEnemy
		aligned.position = Vector2(enemy_x, -350)
		game.room_controller.room.add_child(aligned)
	var piercing_projectile := projectile_scene.instantiate() as TacticalProjectile
	game.room_controller.room.add_child(piercing_projectile)
	piercing_projectile.enemy_hit.connect(func(_enemy: Node): pierce_hits[0] += 1)
	piercing_projectile.configure(
		load("res://game/bullets/resources/piercing.tres"),
		Vector2(-500, -350),
		Vector2.RIGHT
	)
	for _frame in 24:
		await physics_frame
	_expect(pierce_hits[0] == 2, "Piercing rounds must hit multiple aligned enemies.")

	game.room_controller.player.cylinder.clear()
	game.room_controller.active_projectiles = 0
	game.room_controller.enemies_alive = 1
	game.room_controller._on_projectile_resolved(null)
	_expect(game.room_controller.state == RoomController.State.FAILED, "Resolved empty ammo with survivors must fail.")
	game.queue_free()
	await process_frame

	var clear_game := game_scene.instantiate() as GameController
	root.add_child(clear_game)
	await process_frame
	await process_frame
	clear_game._start_level(level.supplied_rounds)
	for enemy in clear_game.room_controller.room.enemies.get_children():
		(enemy as SightEnemy).receive_bullet(normal)
	await process_frame
	_expect(clear_game.state == GameController.State.EXIT_UNLOCKED, "The final enemy must unlock the exit.")
	_expect(not clear_game.room_controller.player.shooting_enabled, "Room clear must disable shooting.")
	_expect(clear_game.room_controller.player.controls_enabled, "Room clear must preserve movement.")
	_expect(not clear_game.room_controller.camera.following, "The camera must reveal the exit first.")
	await create_timer(1.0).timeout
	_expect(clear_game.room_controller.camera.following, "The camera must return to player follow after the reveal.")
	clear_game.queue_free()
	_finish()

func _finish() -> void:
	if failures.is_empty():
		print("CORE LOOP TESTS PASSED")
		quit(0)
	else:
		print("CORE LOOP TESTS FAILED: %d" % failures.size())
		quit(1)
