class_name Enemy extends CharacterBody2D

## Basic enemy behavior: tracks bodies in its detection area, fires when line of
## sight is clear, and handles damage/invincibility.
@export var health = 5
@export var stop_distance = 10
@export var contact_damage = 1
@export var invincibility_duration: float = 0.3
@export var knockback_strength: float = 200.0

@onready var sprite: Sprite2D = $Sprite2D

@onready var timer: Timer = $Timer

@onready var shooting_component: ShootingComponent = $ShootingComponent

@onready var firing_point: Marker2D = $MarkerContainer/FiringPoint

var speed = 25
var chase_player = false
var player = null
var is_invincible: bool = false
var is_knocked_back: bool = false

var _field_of_view: Dictionary[Node2D, RayCast2D]

func _physics_process(_delta: float) -> void:
	_update_line_of_sight()


## Updates each tracked raycast and starts firing while a target is visible.
func _update_line_of_sight() -> void:
	var has_visible_player := false
	for object in _field_of_view:
		if not is_instance_valid(object):
			continue
		var _ray = _field_of_view[object]
		_ray.target_position = to_local(object.global_position)
		_ray.force_raycast_update()
		
		var hit_object = _ray.get_collider()
		
		if hit_object == object:
			has_visible_player = true
			firing_point.rotation = _ray.target_position.angle()
			break

	if has_visible_player:
		if timer.is_stopped():
			timer.start()
	elif not timer.is_stopped():
		timer.stop()


## Adds a temporary raycast for each body that enters the detection area.
func _on_detection_area_body_entered(body: Node2D) -> void:
	if body is Player and not _field_of_view.has(body):
		var _ray = RayCast2D.new()
		_ray.collide_with_areas = true
		_ray.collision_mask = 5
		
		_ray.add_exception(self)
		_ray.add_exception($Detection_Area)
		
		_field_of_view[body] = _ray
		player = body
		add_child(_ray)


## Removes line-of-sight tracking when a body leaves detection range.
func _on_detection_area_body_exited(body: Node2D) -> void:
	if _field_of_view.has(body):
		_field_of_view[body].queue_free()
		_field_of_view.erase(body)
		if player == body:
			player = null


## Deals touch damage to the player when their hitbox enters this enemy.
func _on_hitbox_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		if body.has_method("take_damage"):
			body.take_damage(contact_damage)
	

## Applies bullet damage, death, a brief flash, and invincibility frames.
func take_damage(damage: int) -> void:
	if is_invincible:
		return
	
	health -= damage
	if health <= 0:
		queue_free()
		return
	
	is_invincible = true
	is_knocked_back = true
	
	# Knockback away from the player
	if player:
		var knockback_dir = (global_position - player.global_position).normalized()
		velocity = knockback_dir * knockback_strength
	
	get_tree().create_timer(0.2).timeout.connect(func(): is_knocked_back = false)
	
	# Flash tween
	var tween = create_tween()
	for i in range(3):
		tween.tween_property(sprite, "modulate:a", 0.3, 0.05)
		tween.tween_property(sprite, "modulate:a", 1.0, 0.05)
	
	get_tree().create_timer(invincibility_duration).timeout.connect(func(): is_invincible = false)


## Timer callback used by the detection raycasts to fire enemy shots.
func _on_timer_timeout() -> void:
	shooting_component.shoot()
	
