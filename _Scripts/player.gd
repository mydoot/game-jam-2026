class_name Player extends CharacterBody2D

## Combat avatar spawned by Planning. It connects Stats to HUD, equips Weapon,
## consumes the loadout held by GlobalVariables, and creates GameOver on death.

@export_category("Movement Stats")
@export var speed: float = 150.0
@export var acceleration: float = 1000.0
@export var friction: float = 1000.0

@export_category("Dash Stats")
@export var dash_speed: float = 500
@export var dash_duration: float = 0.15
@export var dash_cooldown: float = 0.8

@export var invincible_duration: float = 1.0

@onready var weapon_socket: Marker2D = $WeaponSocket 
@onready var sprite: Sprite2D = $Sprite2D 
@onready var stats: Stats = $Stats
@onready var hud: CanvasLayer = $HUD

enum State { MOVE, DASH, ATTACK }
var current_state: State = State.MOVE
var game_over_scene: PackedScene = preload("res://Scenes/UI/game_over.tscn")

var current_weapon: Node2D = null
var dash_timer: float = 0.0
var can_dash: bool = true
var walk_bob_timer: float = 0.0
var is_invincible: bool = false

var shooting: bool = false

@onready var gunshot_sfx: AudioStreamPlayer2D = $GunshotSFX

@onready var walk_sfx: AudioStreamPlayer2D = $WalkSFX

## Connects Stats/HUD, equips the default gun, and initializes HUD values that
## Stats emitted before Player's own ready callback.
func _ready() -> void:
	stats.health_changed.connect(hud.update_health)
	stats.bullets_changed.connect(hud.update_bullets)
	stats.died.connect(_on_player_died)
	
	equip_weapon(preload("res://Scenes/Weapons/gun.tscn"))
	hud.update_health(stats.health, stats.max_health)
	hud.update_bullets(stats.bullets, stats.max_bullets)
	hud.update_current_bullet()


## Runs the active movement/attack state and performs CharacterBody2D movement.
func _physics_process(delta: float) -> void:
	match current_state:
		State.MOVE:
			state_move(delta)
		State.ATTACK:
			state_attack(delta)
	
	move_and_slide()


## Default state: aim toward the mouse, move from input, and start attacks.
func state_move(delta: float) -> void:
	_update_aim()
	_apply_movement(Input.get_vector("move_left", "move_right", "move_up", "move_down"), speed, delta)
	
	#walk_sfx.play()
	
	if Input.is_action_just_pressed("attack") and current_weapon != null:
		start_attack()


## Verifies GlobalVariables and Stats both have ammo, spends one round, then asks
## Weapon to spawn the matching bullet.
func start_attack() -> void:
	if not GlobalVariables.has_loaded_bullets():
		return
	if not stats.spend_bullets(1):
		return
		
	current_state = State.ATTACK
	
	# Visual: Slight lunging stop
	velocity = velocity * 0.2 
	
	# Tell the Weapon to do its thing
	if current_weapon.has_method("shoot"):
		shooting = true
		gunshot_sfx.pitch_scale
		gunshot_sfx.play()
		current_weapon.shoot()
		current_state = State.MOVE


## Attack state keeps movement available at a reduced speed while aiming.
func state_attack(delta: float) -> void:
	_update_aim()
	_apply_movement(Input.get_vector("move_left", "move_right", "move_up", "move_down"), speed * 0.75, delta)


## Replaces the current Weapon scene and connects its attack_finished signal so
## HUD advances with the revolver.
func equip_weapon(weapon_scene: PackedScene) -> void:
	if current_weapon:
		current_weapon.queue_free()
	
	var new_weapon = weapon_scene.instantiate()
	weapon_socket.add_child(new_weapon)
	current_weapon = new_weapon
	current_weapon.wielder = self
	
	if new_weapon.has_signal("attack_finished"):
		new_weapon.attack_finished.connect(_on_weapon_finished)


## Refreshes HUD after Weapon consumes the chambered GlobalVariables entry.
func _on_weapon_finished() -> void:
	shooting = false
	hud.update_current_bullet()


## Applies damage unless the player is inside the post-hit invincibility window.
func take_damage(amount: int) -> void:
	if is_invincible:
		return
	
	stats.take_damage(amount)

	is_invincible = true

	var tween = create_tween()
	for i in range(5):
		tween.tween_property(sprite, "modulate:a", 0.3, 0.1)
		tween.tween_property(sprite, "modulate:a", 1.0, 0.1)

	get_tree().create_timer(invincible_duration).timeout.connect(func(): is_invincible = false)
	

## Responds to Stats.died by adding the pause-capable GameOver overlay.
func _on_player_died() -> void:
	var game_over = game_over_scene.instantiate()
	get_tree().current_scene.add_child(game_over)


## Rotates the weapon socket toward the mouse and flips sprites for readability.
func _update_aim() -> void:
	var mouse_position := get_global_mouse_position()
	weapon_socket.look_at(mouse_position)

	if mouse_position.x < global_position.x:
		weapon_socket.scale.y = -1
		sprite.scale.x = -1
	else:
		weapon_socket.scale.y = 1
		sprite.scale.x = 1


## Moves toward input direction or applies friction when no input is held.
func _apply_movement(direction: Vector2, target_speed: float, delta: float) -> void:
	if direction != Vector2.ZERO:
		velocity = velocity.move_toward(direction * target_speed, acceleration * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
