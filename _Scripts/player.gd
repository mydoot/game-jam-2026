class_name Player extends CharacterBody2D

## Combat avatar spawned by CampaignLevel. It moves, aims, fires the ordered
## cylinder, animates the generated directional sheet, and delegates death.
@export var speed := 150.0
@export var acceleration := 1000.0
@export var friction := 1000.0

@onready var weapon_socket: Marker2D = $WeaponSocket
@onready var sprite: Sprite2D = $Sprite2D
@onready var stats: Stats = $Stats
@onready var hud: CanvasLayer = $HUD

var current_weapon: Weapon
var _walk_clock := 0.0
var _facing_column := 0
var _dead := false

## Connects state, equips the revolver, and initializes HUD after Stats readiness.
func _ready() -> void:
	stats.health_changed.connect(hud.update_health)
	stats.bullets_changed.connect(hud.update_bullets)
	stats.died.connect(_on_player_died, CONNECT_ONE_SHOT)
	equip_weapon(preload("res://Scenes/Weapons/gun.tscn"))
	hud.update_health(stats.health, stats.max_health)
	hud.update_bullets(stats.bullets, stats.max_bullets)
	hud.update_current_bullet()

## Applies movement, animation, aiming, firing, and body collision in combat.
func _physics_process(delta: float) -> void:
	if _dead:
		velocity = Vector2.ZERO
		return
	var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	_apply_movement(direction, delta)
	_update_animation(direction, delta)
	_update_aim()
	if Input.is_action_just_pressed("attack") and current_weapon:
		start_attack()
	move_and_slide()

## Fires only when CampaignLevel is actively accepting projectiles.
func start_attack() -> void:
	if not GlobalVariables.has_loaded_bullets() or stats.bullets <= 0:
		return
	var level := get_tree().get_first_node_in_group("level") as CampaignLevel
	if level == null or level.phase != CampaignLevel.LevelPhase.COMBAT:
		return
	velocity *= 0.35
	if current_weapon.shoot():
		stats.spend_bullets(1)

## Replaces the current revolver and reconnects the HUD chamber update.
func equip_weapon(weapon_scene: PackedScene) -> void:
	if current_weapon:
		current_weapon.queue_free()
	current_weapon = weapon_scene.instantiate() as Weapon
	weapon_socket.add_child(current_weapon)
	current_weapon.wielder = self
	current_weapon.attack_finished.connect(_on_weapon_finished)

## Refreshes the chamber icon after Weapon consumes one round.
func _on_weapon_finished() -> void:
	hud.update_current_bullet()

## Applies one-hit damage until death disables all player input.
func take_damage(amount: int) -> void:
	if _dead:
		return
	stats.take_damage(amount)

## Reports death exactly once through CampaignLevel's terminal guard.
func _on_player_died() -> void:
	_dead = true
	var level := get_tree().get_first_node_in_group("level") as CampaignLevel
	if level:
		level.finish_attempt(false, "Caught in a sentry's line of fire")

## Rotates the hidden weapon marker toward the mouse firing direction.
func _update_aim() -> void:
	weapon_socket.look_at(get_global_mouse_position())

## Moves toward input or decelerates with frame-rate-independent friction.
func _apply_movement(direction: Vector2, delta: float) -> void:
	if direction != Vector2.ZERO:
		velocity = velocity.move_toward(direction * speed, acceleration * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)

## Selects one of four direction cells and idle/walk rows in the sprite sheet.
func _update_animation(direction: Vector2, delta: float) -> void:
	if direction != Vector2.ZERO:
		if absf(direction.x) > absf(direction.y):
			_facing_column = 3 if direction.x > 0.0 else 1
		else:
			_facing_column = 0 if direction.y > 0.0 else 2
		_walk_clock += delta
	else:
		_walk_clock = 0.0
	var walking_row := 1 if direction != Vector2.ZERO and fmod(_walk_clock, 0.36) >= 0.18 else 0
	sprite.region_rect = Rect2(_facing_column * 384, walking_row * 512, 384, 512)
