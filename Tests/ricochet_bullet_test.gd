extends SceneTree

const BULLET_SCENE := preload("res://Scenes/Weapons/Bullet.tscn")

var failures: Array[String] = []


class TestEnemy:
	extends CharacterBody2D

	var health: int = 2

	func _init() -> void:
		collision_layer = 1
		collision_mask = 0
		add_to_group("enemy")

		var collision_shape := CollisionShape2D.new()
		var rectangle := RectangleShape2D.new()
		rectangle.size = Vector2(20.0, 20.0)
		collision_shape.shape = rectangle
		add_child(collision_shape)

	func take_damage(amount: int) -> void:
		health -= amount


func _initialize() -> void:
	call_deferred("_run_tests")


func _run_tests() -> void:
	await _test_scaled_spawn_and_body_bounce()
	await _test_area_bounce()
	await _test_angled_reflection()
	await _test_second_wall_destroys_bullet()
	await _test_enemy_after_bounce()
	await _test_normal_and_piercing_regressions()

	if failures.is_empty():
		print("PASS: native bullet and ricochet regression suite")
		quit(0)
		return

	for failure in failures:
		push_error(failure)
	quit(1)


func _test_scaled_spawn_and_body_bounce() -> void:
	var world := _new_world()
	_add_body_wall(world, Vector2(60.0, 0.0))
	await physics_frame

	var bullet := _spawn_bullet(
		world,
		_new_ricochet_config(),
		Vector2.ZERO,
		Vector2.RIGHT,
		Vector2(0.35, -0.35)
	)
	var bullet_ref: WeakRef = weakref(bullet)
	var bounce_state := {"count": 0}
	bullet.bounced.connect(func(_position: Vector2, _normal: Vector2) -> void:
		bounce_state["count"] += 1
	)

	_check(
		bullet.global_scale.is_equal_approx(Vector2.ONE),
		"Ricochet configure must clear inherited player/mirror scale."
	)
	var did_bounce := await _wait_until(
		func() -> bool: return bounce_state["count"] == 1 or bullet_ref.get_ref() == null
	)
	_check(did_bounce and is_instance_valid(bullet), "Ricochet did not survive its first body-wall contact.")
	if is_instance_valid(bullet):
		_check(bullet.direction.x < -0.99, "Vertical wall did not reflect the ricochet to the left.")
		await physics_frame
		_check(is_instance_valid(bullet), "Ricochet disappeared on the physics frame after bouncing.")
		_check(bounce_state["count"] == 1, "A single wall contact emitted more than one bounce.")

	await _free_world(world)


func _test_area_bounce() -> void:
	var world := _new_world()
	_add_area_wall(world, Vector2(60.0, 0.0))
	await physics_frame

	var bullet := _spawn_bullet(world, _new_ricochet_config(), Vector2.ZERO, Vector2.RIGHT)
	var bullet_ref: WeakRef = weakref(bullet)
	var bounce_state := {"count": 0}
	bullet.bounced.connect(func(_position: Vector2, _normal: Vector2) -> void:
		bounce_state["count"] += 1
	)

	var did_bounce := await _wait_until(
		func() -> bool: return bounce_state["count"] == 1 or bullet_ref.get_ref() == null
	)
	_check(did_bounce and is_instance_valid(bullet), "Ricochet did not survive an Area2D wall contact.")
	if is_instance_valid(bullet):
		await physics_frame
		_check(is_instance_valid(bullet), "Area2D wall was immediately counted as a second impact.")

	await _free_world(world)


func _test_angled_reflection() -> void:
	var world := _new_world()
	_add_body_wall(world, Vector2(60.0, 0.0), PI / 4.0)
	await physics_frame

	var bullet := _spawn_bullet(world, _new_ricochet_config(), Vector2.ZERO, Vector2.RIGHT)
	var bullet_ref: WeakRef = weakref(bullet)
	var bounce_state := {"count": 0, "normal": Vector2.ZERO}
	bullet.bounced.connect(func(_position: Vector2, normal: Vector2) -> void:
		bounce_state["count"] += 1
		bounce_state["normal"] = normal
	)

	var did_bounce := await _wait_until(
		func() -> bool: return bounce_state["count"] == 1 or bullet_ref.get_ref() == null
	)
	_check(did_bounce and is_instance_valid(bullet), "Ricochet did not survive an angled wall contact.")
	if is_instance_valid(bullet):
		var expected_direction := Vector2.RIGHT.bounce(bounce_state["normal"]).normalized()
		_check(
			bullet.direction.dot(expected_direction) > 0.999,
			"Angled wall reflection does not match Vector2.bounce(collision_normal)."
		)

	await _free_world(world)


func _test_second_wall_destroys_bullet() -> void:
	var world := _new_world()
	_add_body_wall(world, Vector2(60.0, 0.0))
	_add_body_wall(world, Vector2(-60.0, 0.0))
	await physics_frame

	var bullet := _spawn_bullet(world, _new_ricochet_config(), Vector2.ZERO, Vector2.RIGHT)
	var bullet_ref: WeakRef = weakref(bullet)
	var bounce_state := {"count": 0}
	bullet.bounced.connect(func(_position: Vector2, _normal: Vector2) -> void:
		bounce_state["count"] += 1
	)

	var did_bounce := await _wait_until(
		func() -> bool: return bounce_state["count"] == 1 or bullet_ref.get_ref() == null
	)
	_check(did_bounce and is_instance_valid(bullet), "Two-wall test bullet did not survive its first wall.")
	if is_instance_valid(bullet):
		await physics_frame
		_check(is_instance_valid(bullet), "First wall was immediately treated as the second wall.")
		var was_destroyed := await _wait_until(func() -> bool: return bullet_ref.get_ref() == null)
		_check(was_destroyed, "Ricochet was not destroyed by its second wall.")
	_check(bounce_state["count"] == 1, "Ricochet bounced more than once.")

	await _free_world(world)


func _test_enemy_after_bounce() -> void:
	var world := _new_world()
	_add_body_wall(world, Vector2(60.0, 0.0))
	var enemy := TestEnemy.new()
	enemy.position = Vector2(-120.0, 0.0)
	world.add_child(enemy)
	await physics_frame

	var bullet := _spawn_bullet(world, _new_ricochet_config(), Vector2.ZERO, Vector2.RIGHT)
	var bullet_ref: WeakRef = weakref(bullet)
	var bounce_state := {"count": 0}
	bullet.bounced.connect(func(_position: Vector2, _normal: Vector2) -> void:
		bounce_state["count"] += 1
	)

	var damaged_enemy := await _wait_until(
		func() -> bool: return enemy.health == 1
	)
	_check(damaged_enemy, "Post-bounce ricochet did not damage the enemy once.")
	_check(bounce_state["count"] == 1, "Post-bounce enemy test did not use exactly one wall bounce.")
	var bullet_was_destroyed := await _wait_until(func() -> bool: return bullet_ref.get_ref() == null, 10)
	_check(bullet_was_destroyed, "Ricochet survived after damaging an enemy.")

	await _free_world(world)


func _test_normal_and_piercing_regressions() -> void:
	var normal_world := _new_world()
	_add_body_wall(normal_world, Vector2(60.0, 0.0))
	await physics_frame

	var normal_bullet := _spawn_bullet(
		normal_world,
		_new_basic_config(),
		Vector2.ZERO,
		Vector2.RIGHT
	)
	var normal_bullet_ref: WeakRef = weakref(normal_bullet)
	var normal_destroyed := await _wait_until(func() -> bool: return normal_bullet_ref.get_ref() == null)
	_check(normal_destroyed, "Normal bullet no longer stops at its first wall.")
	await _free_world(normal_world)

	var piercing_world := _new_world()
	var first_enemy := TestEnemy.new()
	first_enemy.position = Vector2(60.0, 0.0)
	piercing_world.add_child(first_enemy)
	var second_enemy := TestEnemy.new()
	second_enemy.position = Vector2(180.0, 0.0)
	piercing_world.add_child(second_enemy)
	await physics_frame

	var piercing_bullet := _spawn_bullet(
		piercing_world,
		_new_piercing_config(),
		Vector2.ZERO,
		Vector2.RIGHT
	)
	var hit_both := await _wait_until(
		func() -> bool:
			return (
				is_instance_valid(first_enemy)
				and is_instance_valid(second_enemy)
				and first_enemy.health == 1
				and second_enemy.health == 1
			)
	)
	_check(hit_both, "Piercing bullet did not damage and pass through both enemies.")
	_check(is_instance_valid(piercing_bullet), "Piercing bullet was destroyed by an enemy.")

	await _free_world(piercing_world)


func _new_world() -> Node2D:
	var world := Node2D.new()
	root.add_child(world)
	return world


func _add_body_wall(parent: Node, wall_position: Vector2, wall_rotation: float = 0.0) -> void:
	var wall := StaticBody2D.new()
	wall.collision_layer = 4
	wall.collision_mask = 0
	wall.position = wall_position
	wall.rotation = wall_rotation
	parent.add_child(wall)
	_add_wall_shape(wall)


func _add_area_wall(parent: Node, wall_position: Vector2) -> void:
	var wall := Area2D.new()
	wall.collision_layer = 4
	wall.collision_mask = 0
	wall.position = wall_position
	parent.add_child(wall)
	_add_wall_shape(wall)


func _add_wall_shape(wall: CollisionObject2D) -> void:
	var collision_shape := CollisionShape2D.new()
	var rectangle := RectangleShape2D.new()
	rectangle.size = Vector2(10.0, 200.0)
	collision_shape.shape = rectangle
	wall.add_child(collision_shape)


func _spawn_bullet(
		parent: Node,
		config: BasicBullet,
		start_position: Vector2,
		travel_direction: Vector2,
		inherited_scale: Vector2 = Vector2.ONE
) -> PlayerBullet:
	var bullet := BULLET_SCENE.instantiate() as PlayerBullet
	parent.add_child(bullet)
	bullet.global_position = start_position
	bullet.global_scale = inherited_scale
	bullet.configure(config, 1, travel_direction, null)
	return bullet


func _new_basic_config() -> BasicBullet:
	var config := BasicBullet.new()
	_configure_test_bullet(config)
	return config


func _new_ricochet_config() -> RicochetBullet:
	var config := RicochetBullet.new()
	_configure_test_bullet(config)
	return config


func _new_piercing_config() -> PiercingBullet:
	var config := PiercingBullet.new()
	_configure_test_bullet(config)
	return config


func _configure_test_bullet(config: BasicBullet) -> void:
	config.bullet_max_lifetime = 3.0
	config.bullet_collision_shape_size = Vector2(8.0, 8.0)
	config.bullet_texture_size = Vector2(8.0, 8.0)
	config.min_speed = 600.0
	config.max_speed = 600.0
	config.minimum_max_speed = 600.0
	config.maximum_max_speed = 600.0
	config.min_accel = 0.0
	config.max_accel = 0.0


func _wait_until(condition: Callable, max_frames: int = 240) -> bool:
	for _frame in range(max_frames):
		await physics_frame
		if condition.call():
			return true
	return false


func _check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)


func _free_world(world: Node) -> void:
	if is_instance_valid(world):
		world.queue_free()
	await process_frame
