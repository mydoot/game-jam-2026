class_name RoomController
extends Node

signal room_started
signal enemy_count_changed(remaining: int)
signal room_cleared
signal room_failed(reason: String)
signal exit_entered

enum State { PLANNING, PLAYING, EXIT_UNLOCKED, FAILED, COMPLETE }

@export var player_scene: PackedScene
@export var camera_scene: PackedScene

var state := State.PLANNING
var room: RoomRoot
var player: RevolverPlayer
var camera: GameCamera
var exit_door: ExitDoor
var enemies_alive := 0
var active_projectiles := 0

func setup(authored_room: RoomRoot) -> void:
	room = authored_room
	state = State.PLANNING
	active_projectiles = 0
	player = player_scene.instantiate() as RevolverPlayer
	room.add_child(player)
	player.global_position = room.player_spawn.global_position
	camera = camera_scene.instantiate() as GameCamera
	room.add_child(camera)
	camera.show_room(room.get_center(), room.room_size)
	exit_door = room.exit_door
	exit_door.set_unlocked(false)
	exit_door.entered.connect(_on_exit_entered)
	var enemies := room.configure_enemies(player)
	enemies_alive = enemies.size()
	for enemy in enemies:
		enemy.defeated.connect(_on_enemy_defeated)
	for wall in room.get_tree().get_nodes_in_group("destructible_terrain"):
		if room.is_ancestor_of(wall):
			wall.destroyed.connect(_on_terrain_destroyed)
	player.shot_fired.connect(_on_shot_fired)
	player.died.connect(func(): fail_room("YOU DIED"))
	enemy_count_changed.emit(enemies_alive)

func start(rounds: Array[BulletDefinition]) -> bool:
	if state != State.PLANNING or rounds.size() != 6:
		return false
	state = State.PLAYING
	player.load_cylinder(rounds)
	player.set_controls_enabled(true)
	for enemy in room.enemies.get_children():
		if enemy is SightEnemy:
			enemy.activate()
	camera.follow_player(player)
	room_started.emit()
	return true

func fail_room(reason: String) -> void:
	if state != State.PLAYING:
		return
	state = State.FAILED
	player.set_controls_enabled(false)
	room.process_mode = Node.PROCESS_MODE_DISABLED
	room_failed.emit(reason)

func mark_complete() -> void:
	state = State.COMPLETE
	player.set_controls_enabled(false)
	room.process_mode = Node.PROCESS_MODE_DISABLED

func _on_shot_fired(_rounds_left: int, projectile: TacticalProjectile) -> void:
	active_projectiles += 1
	projectile.resolved.connect(_on_projectile_resolved, CONNECT_ONE_SHOT)

func _on_projectile_resolved(_projectile: TacticalProjectile) -> void:
	active_projectiles = maxi(0, active_projectiles - 1)
	if state == State.PLAYING and player.cylinder.is_empty() and active_projectiles == 0 and enemies_alive > 0:
		fail_room("OUT OF AMMO")

func _on_enemy_defeated(_enemy: SightEnemy) -> void:
	enemies_alive = maxi(0, enemies_alive - 1)
	enemy_count_changed.emit(enemies_alive)
	if enemies_alive == 0 and state == State.PLAYING:
		state = State.EXIT_UNLOCKED
		player.set_shooting_enabled(false)
		exit_door.set_unlocked(true)
		camera.show_room(exit_door.global_position, Vector2(500, 340))
		_return_to_player_camera()
		room_cleared.emit()

func _return_to_player_camera() -> void:
	await get_tree().create_timer(0.85).timeout
	if state == State.EXIT_UNLOCKED and is_instance_valid(player) and is_instance_valid(camera):
		camera.follow_player(player)

func _on_terrain_destroyed(_wall: DestructibleWall) -> void:
	for enemy in room.enemies.get_children():
		if enemy is SightEnemy:
			enemy.queue_redraw()

func _on_exit_entered() -> void:
	if state == State.EXIT_UNLOCKED:
		exit_entered.emit()

