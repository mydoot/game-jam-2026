class_name Enemy extends CharacterBody2D

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
var chasePlayer = false
var player = null
var is_invincible: bool = false
var is_knocked_back: bool = false

var _field_of_view: Dictionary[Node2D, RayCast2D]
#var _ray: RayCast2D

func _physics_process(delta: float) -> void:
	#if is_knocked_back:
		#velocity = velocity.move_toward(Vector2.ZERO, 400.0 * delta)
		#move_and_slide()
		#return
	
	for object in _field_of_view:
		var _ray = _field_of_view[object]
		_ray.target_position = to_local(object.global_position)
		_ray.force_raycast_update()
		
		var hit_object = _ray.get_collider()
		
		if hit_object == object:
			#print("Character is in my sight")
			firing_point.rotation = _ray.target_position.angle()
			if timer.is_stopped():
				timer.start()
		elif hit_object is Area2D:
			#print("wall")
			pass
			
	
	#move_and_slide()


func _on_detection_area_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D:
		var _ray = RayCast2D.new()
		_ray.collide_with_areas = true
		_ray.collision_mask = 3 # Layer 3 contains the walls
		
		_ray.add_exception(self)
		_ray.add_exception($Detection_Area)
		
		_field_of_view[body] = _ray
		add_child(_ray)


func _on_detection_area_body_exited(body: Node2D) -> void:
	if _field_of_view.has(body):
		_field_of_view[body].queue_free()
		_field_of_view.erase(body)
		if !timer.is_stopped():
				timer.stop()

#func _on_detection_area_area_entered(area: Area2D) -> void:
	#_ray = RayCast2D.new()
	#_ray.collide_with_areas = true
	#_field_of_view[area] = _ray
	#add_child(_ray)
#
#
#func _on_detection_area_area_exited(area: Area2D) -> void:
	#_field_of_view[area].queue_free()
	#_field_of_view.erase(area)

func _on_hitbox_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		if body.has_method("take_damage"):
			body.take_damage(contact_damage, global_position)
	
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


func _on_timer_timeout() -> void:
	print("firing shot!")
	# The enemy is firing enemy_bullet.tres which is just a very fast projectile
	# It would probably be better for the enemy to fire a raycast shot to insta kill the player, but this is an easy implementation for now
	shooting_component.shoot()
	
