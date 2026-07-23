class_name RevolverPlayer
extends CharacterBody2D

signal health_changed(current: int, maximum: int)
signal cylinder_changed(rounds: Array[BulletDefinition])
signal shot_fired(rounds_left: int, projectile: TacticalProjectile)
signal died

@export var speed := 170.0
@export var acceleration := 1100.0
@export var friction := 1200.0
@export var max_health := 3
@export var fire_cooldown := 0.18
@export var projectile_scene: PackedScene

var health := 3
var controls_enabled := false
var shooting_enabled := true
var cylinder: Array[BulletDefinition] = []
var is_invincible := false
var _fire_timer := 0.0

func _ready() -> void:
	health = max_health

func load_cylinder(rounds: Array[BulletDefinition]) -> void:
	cylinder = rounds.duplicate()
	cylinder_changed.emit(cylinder)

func set_controls_enabled(value: bool) -> void:
	controls_enabled = value
	if not value:
		velocity = Vector2.ZERO

func set_shooting_enabled(value: bool) -> void:
	shooting_enabled = value

func _physics_process(delta: float) -> void:
	_fire_timer = maxf(0.0, _fire_timer - delta)
	if not controls_enabled:
		return
	var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var change_rate := acceleration if not direction.is_zero_approx() else friction
	velocity = velocity.move_toward(direction * speed, change_rate * delta)
	move_and_slide()
	_update_aim()
	if Input.is_action_just_pressed("attack"):
		shoot()

func shoot() -> void:
	if cylinder.is_empty() or _fire_timer > 0.0 or not controls_enabled or not shooting_enabled:
		return
	_fire_timer = fire_cooldown
	var bullet: BulletDefinition = cylinder.pop_front()
	var aim := (get_global_mouse_position() - global_position).normalized()
	if aim.is_zero_approx():
		aim = Vector2.RIGHT
	var projectile := projectile_scene.instantiate() as TacticalProjectile
	get_parent().add_child(projectile)
	projectile.configure(bullet, global_position + aim * 24.0, aim)
	cylinder_changed.emit(cylinder)
	shot_fired.emit(cylinder.size(), projectile)

func take_damage(amount: int, source_position: Vector2) -> void:
	if is_invincible or not controls_enabled:
		return
	health = maxi(0, health - amount)
	health_changed.emit(health, max_health)
	if health == 0:
		set_controls_enabled(false)
		died.emit()
		return
	is_invincible = true
	velocity = (global_position - source_position).normalized() * 280.0
	modulate = Color(1, 1, 1, 0.35)
	get_tree().create_timer(0.7).timeout.connect(_end_invincibility)

func _end_invincibility() -> void:
	if is_instance_valid(self):
		is_invincible = false
		modulate = Color.WHITE

func _update_aim() -> void:
	var aim := (get_global_mouse_position() - global_position).normalized()
	if not aim.is_zero_approx():
		($Aim as Line2D).points = PackedVector2Array([Vector2.ZERO, aim * 25.0])
