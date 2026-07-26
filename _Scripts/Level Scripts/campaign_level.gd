class_name CampaignLevel extends Node2D

## Complete preview, planning, combat, clear/fail, and exit state machine.
enum LevelPhase { PREVIEW, COMBAT, CLEARED, FAILED, EXITING }
signal phase_changed(phase: LevelPhase)
signal enemy_count_changed(remaining: int)

@export_range(1, 6) var level_index := 1
const TILE_SIZE := 32
const MAP_SIZE := Vector2i(40, 22)
const TILE_SET := preload("res://Sprites/tile_set.tres")
const ENEMY_SCENE := preload("res://Scenes/Enemies/enemy.tscn")
const PLAYER_SCENE := preload("res://Scenes/player.tscn")
const PLANNING_SCENE := preload("res://Scenes/UI/planning.tscn")
const GAME_OVER_SCENE := preload("res://Scenes/UI/game_over.tscn")
const PAUSE_SCENE := preload("res://Scenes/UI/pause_menu.tscn")
const EXIT_SHEET := preload("res://Assets/Generated/exit_sheet.png")

var phase := LevelPhase.PREVIEW
var active_projectiles := 0
var enemies_alive := 0
var combat_time := 0.0
var definition: Resource
var player: Player
var camera: Camera2D
var exit_area: Area2D
var exit_sprite: Sprite2D
var status_label: Label
var enemies: Array[Enemy] = []
var _terminal_guard := false

## Builds the selected room and opens its loadout planner.
func _ready() -> void:
	add_to_group("level")
	GameState.current_level = level_index
	GlobalVariables.clear_bullet_loadout()
	definition = GameState.get_level_definition(level_index)
	if definition == null or not definition.is_valid():
		push_error("Level %d has an invalid definition." % level_index)
		return
	_build_room()
	_spawn_enemies()
	_build_exit()
	_build_camera()
	_build_level_header()
	_open_planning()

## Tracks combat time and pause input.
func _process(delta: float) -> void:
	if phase == LevelPhase.COMBAT:
		combat_time += delta
	if Input.is_action_just_pressed("ui_cancel") and phase in [LevelPhase.PREVIEW, LevelPhase.COMBAT]:
		_open_pause()

## Constructs floor, boundaries, and authored collidable cover.
func _build_room() -> void:
	var floor := TileMapLayer.new()
	floor.name = "Floor"
	floor.tile_set = TILE_SET
	floor.z_index = -3
	add_child(floor)
	var walls := TileMapLayer.new()
	walls.name = "Walls"
	walls.tile_set = TILE_SET
	walls.z_index = -2
	add_child(walls)
	for y in MAP_SIZE.y:
		for x in MAP_SIZE.x:
			floor.set_cell(Vector2i(x, y), 1, Vector2i(4, 0))
			if x == 0 or y == 0 or x == MAP_SIZE.x - 1 or y == MAP_SIZE.y - 1:
				walls.set_cell(Vector2i(x, y), 1, Vector2i(2, 1))
	for rect in definition.walls:
		for y in range(rect.position.y, rect.end.y):
			for x in range(rect.position.x, rect.end.x):
				walls.set_cell(Vector2i(x, y), 1, Vector2i(2, 1))

## Instantiates locally owned sentries from typed placements.
func _spawn_enemies() -> void:
	for placement in definition.enemies:
		var enemy := ENEMY_SCENE.instantiate() as Enemy
		enemy.position = _tile_center(placement.tile)
		enemy.rotation = placement.facing_radians
		enemy.sight_range = placement.sight_range
		enemy.fire_delay = placement.fire_delay
		enemy.requires_ricochet = placement.requires_ricochet
		enemy.died.connect(_on_enemy_died)
		add_child(enemy)
		enemies.append(enemy)
	enemies_alive = enemies.size()
	enemy_count_changed.emit(enemies_alive)

## Creates a locked exit whose art changes after room clear.
func _build_exit() -> void:
	exit_area = Area2D.new()
	exit_area.name = "Exit"
	exit_area.position = _tile_center(definition.exit)
	exit_area.collision_mask = 1
	exit_area.body_entered.connect(_on_exit_entered)
	add_child(exit_area)
	var collision := CollisionShape2D.new()
	var shape := CircleShape2D.new()
	shape.radius = 26.0
	collision.shape = shape
	exit_area.add_child(collision)
	exit_sprite = Sprite2D.new()
	exit_sprite.texture = _exit_texture(false)
	exit_sprite.scale = Vector2.ONE * 0.052
	exit_area.add_child(exit_sprite)
	var label := Label.new()
	label.name = "StateLabel"
	label.text = "LOCKED"
	label.position = Vector2(-30, 30)
	label.add_theme_color_override("font_color", Color(1.0, 0.45, 0.4))
	exit_area.add_child(label)

## Creates the full-room preview camera.
func _build_camera() -> void:
	camera = Camera2D.new()
	camera.position = Vector2(MAP_SIZE * TILE_SIZE) * 0.5
	camera.zoom = Vector2(0.92, 0.92)
	camera.limit_right = MAP_SIZE.x * TILE_SIZE
	camera.limit_bottom = MAP_SIZE.y * TILE_SIZE
	add_child(camera)

## Creates the persistent objective text.
func _build_level_header() -> void:
	var canvas := CanvasLayer.new()
	canvas.layer = 5
	add_child(canvas)
	status_label = Label.new()
	status_label.position = Vector2(18, 48)
	status_label.add_theme_font_size_override("font_size", 18)
	canvas.add_child(status_label)
	_update_status()

## Opens planning with exactly six catalog bullets.
func _open_planning() -> void:
	var planning := PLANNING_SCENE.instantiate() as PlanningUI
	planning.available_bullets = GameState.get_level_bullets(level_index)
	planning.start_requested.connect(_start_combat)
	add_child(planning)

## Transfers the ordered cylinder and starts local combat.
func _start_combat(ordered_bullets: Array[Resource]) -> void:
	if phase != LevelPhase.PREVIEW or ordered_bullets.size() != 6:
		return
	GlobalVariables.set_bullet_loadout(ordered_bullets)
	_set_phase(LevelPhase.COMBAT)
	player = PLAYER_SCENE.instantiate() as Player
	add_child(player)
	player.position = _tile_center(definition.spawn)
	for enemy in enemies:
		if is_instance_valid(enemy):
			enemy.set_target(player)
			enemy.set_combat_active(true)
	var planning := get_node_or_null("Planning")
	if planning:
		planning.queue_free()
	if DisplayServer.get_name() == "headless":
		camera.global_position = player.global_position
		camera.zoom = Vector2(1.35, 1.35)
		camera.reparent(player, true)
		camera.position = Vector2.ZERO
		return
	var tween := create_tween().set_parallel(true)
	tween.tween_property(camera, "global_position", player.global_position, 0.5)
	tween.tween_property(camera, "zoom", Vector2(1.35, 1.35), 0.5)
	await tween.finished
	if is_instance_valid(player) and phase == LevelPhase.COMBAT:
		camera.reparent(player, true)
		camera.position = Vector2.ZERO

## Tracks an accepted projectile until its resolution signal.
func register_projectile(projectile: PlayerProjectile) -> bool:
	if phase != LevelPhase.COMBAT or projectile == null:
		return false
	active_projectiles += 1
	projectile.resolved.connect(_on_projectile_resolved, CONNECT_ONE_SHOT)
	return true

## Fails only after the last live projectile and chamber are both gone.
func _on_projectile_resolved(_projectile: PlayerProjectile) -> void:
	active_projectiles = maxi(active_projectiles - 1, 0)
	if phase == LevelPhase.COMBAT and active_projectiles == 0 and not GlobalVariables.has_loaded_bullets() and enemies_alive > 0:
		finish_attempt(false, "Out of bullets")

## Updates the local count and unlocks the exit after the final enemy.
func _on_enemy_died(enemy: Enemy) -> void:
	enemies.erase(enemy)
	enemies_alive = enemies.size()
	enemy_count_changed.emit(enemies_alive)
	if enemies_alive == 0 and phase == LevelPhase.COMBAT:
		finish_attempt(true)
	_update_status()

## Saves progress and transitions only from an unlocked exit.
func _on_exit_entered(body: Node2D) -> void:
	if not (body is Player) or phase != LevelPhase.CLEARED or _terminal_guard:
		return
	_terminal_guard = true
	_set_phase(LevelPhase.EXITING)
	GameState.complete_level(level_index, combat_time)
	SfxBus.play_ui(&"exit")
	if level_index < GameState.LEVEL_COUNT:
		GameState.load_level(level_index + 1)
	else:
		SceneLoader.load_scene(GameState.VICTORY)

## Performs the sole success/failure phase transition.
func finish_attempt(succeeded: bool, reason := "") -> bool:
	if _terminal_guard or phase not in [LevelPhase.COMBAT, LevelPhase.PREVIEW]:
		return false
	if succeeded:
		_set_phase(LevelPhase.CLEARED)
		exit_sprite.texture = _exit_texture(true)
		var label := exit_area.get_node("StateLabel") as Label
		label.text = "OPEN"
		label.add_theme_color_override("font_color", Color(0.35, 1.0, 0.55))
		if DisplayServer.get_name() != "headless":
			var pulse := create_tween().set_loops()
			pulse.tween_property(exit_sprite, "modulate", Color(0.65, 1.0, 0.7), 0.5)
			pulse.tween_property(exit_sprite, "modulate", Color.WHITE, 0.5)
		for enemy in enemies:
			if is_instance_valid(enemy):
				enemy.set_combat_active(false)
		SfxBus.play_ui(&"exit")
		return true
	_terminal_guard = true
	_set_phase(LevelPhase.FAILED)
	var overlay := GAME_OVER_SCENE.instantiate()
	add_child(overlay)
	overlay.setup(reason)
	SfxBus.play_ui(&"failure")
	return true

## Compatibility failure entry used by Player.
func fail_level(reason: String) -> void:
	finish_attempt(false, reason)

## Adds one process-always pause overlay.
func _open_pause() -> void:
	if not get_node_or_null("PauseMenu"):
		add_child(PAUSE_SCENE.instantiate())

## Applies a short camera recoil.
func shake_camera(strength: float) -> void:
	if camera == null or phase != LevelPhase.COMBAT:
		return
	camera.offset = Vector2(strength, -strength * 0.5)
	camera.create_tween().tween_property(camera, "offset", Vector2.ZERO, 0.1)

## Refreshes title, mechanic hint, and objective.
func _update_status() -> void:
	if status_label == null:
		return
	var objective := "Preview the room and order all six rounds"
	if phase == LevelPhase.COMBAT:
		objective = "Sentries remaining: %d" % enemies_alive
	elif phase == LevelPhase.CLEARED:
		objective = "Room clear — reach the OPEN exit"
	status_label.text = "LEVEL %d — %s\n%s\n%s" % [level_index, definition.title, definition.brief, objective]

## Changes phase once and publishes it.
func _set_phase(new_phase: LevelPhase) -> void:
	phase = new_phase
	phase_changed.emit(phase)
	_update_status()

## Returns the locked or open half of the generated exit sheet.
func _exit_texture(unlocked: bool) -> AtlasTexture:
	var texture := AtlasTexture.new()
	texture.atlas = EXIT_SHEET
	texture.region = Rect2(627 if unlocked else 0, 0, 627, 1254)
	return texture

## Converts a tile coordinate to its pixel center.
func _tile_center(tile: Vector2i) -> Vector2:
	return Vector2(tile * TILE_SIZE) + Vector2(TILE_SIZE, TILE_SIZE) * 0.5
