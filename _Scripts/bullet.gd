class_name PlayerBullet extends Node2D

## Native Godot projectile configured from a BasicBullet resource. ShapeCast2D
## sweeps the configured collision shape so fast bullets do not skip thin walls.
@export_flags_2d_physics var collision_mask: int = 5

@onready var sprite: Sprite2D = $Sprite2D
@onready var shape_cast: ShapeCast2D = $ShapeCast2D

const bullet_collision_vfx = preload("res://Assets/VFX/bullet_collision_vfx.tscn")

signal bounced(collision_position: Vector2, collision_normal: Vector2)

var bullet_resource: BasicBullet
var damage: int = 1
var direction: Vector2 = Vector2.RIGHT
var speed: float = 0.0
var maximum_speed: float = 0.0
var acceleration: float = 0.0
var remaining_lifetime: float = 0.0
var remaining_bounces: int = 0
var is_piercing: bool = false
var texture_elapsed: float = 0.0
var texture_index: int = 0


## Applies per-shot configuration after Weapon adds this projectile to the tree.
func configure(
		config: BasicBullet,
		bullet_damage: int,
		travel_direction: Vector2,
		shooter: CollisionObject2D
) -> void:
	bullet_resource = config
	damage = bullet_damage
	direction = travel_direction.normalized()
	if direction == Vector2.ZERO:
		direction = Vector2.RIGHT
	# Projectiles live under the level root and must not inherit the player's
	# scale, skew, or mirrored weapon transform. Rebuilding the transform is
	# required because negative 2D scales are ambiguous when decomposed.
	global_transform = Transform2D(direction.angle(), global_position)

	speed = randf_range(
		minf(config.min_speed, config.max_speed),
		maxf(config.min_speed, config.max_speed)
	)
	maximum_speed = randf_range(
		minf(config.minimum_max_speed, config.maximum_max_speed),
		maxf(config.minimum_max_speed, config.maximum_max_speed)
	)
	acceleration = randf_range(
		minf(config.min_accel, config.max_accel),
		maxf(config.min_accel, config.max_accel)
	)
	remaining_lifetime = config.bullet_max_lifetime
	remaining_bounces = config.wall_bounce_count()
	is_piercing = config.pierces_enemies()

	_apply_visuals()
	_apply_collision_shape()
	shape_cast.collision_mask = collision_mask
	if shooter != null:
		shape_cast.add_exception_rid(shooter.get_rid())


func _physics_process(delta: float) -> void:
	if bullet_resource == null:
		return

	remaining_lifetime -= delta
	if remaining_lifetime <= 0.0:
		queue_free()
		return

	speed = move_toward(speed, maximum_speed, acceleration * delta)
	_move_projectile(speed * delta)
	_update_texture(delta)


## Resolves a small bounded number of contacts per frame so a piercing shot or
## ricochet can consume the rest of its movement without tunnelling.
func _move_projectile(distance: float) -> void:
	var remaining_distance := distance

	for _contact_index in range(4):
		if remaining_distance <= 0.0 or is_queued_for_deletion():
			return

		shape_cast.target_position = Vector2.RIGHT * remaining_distance
		shape_cast.force_shapecast_update()

		if not shape_cast.is_colliding():
			global_position += direction * remaining_distance
			return

		var safe_fraction := shape_cast.get_closest_collision_safe_fraction()
		var traveled_distance := remaining_distance * safe_fraction
		global_position += direction * traveled_distance
		remaining_distance -= traveled_distance

		var collider := shape_cast.get_collider(0)
		var collider_rid := shape_cast.get_collider_rid(0)
		var collision_normal := shape_cast.get_collision_normal(0)

		if (
			collider is Node
			and collider.is_in_group("enemy")
			and collider.has_method("take_damage")
		):
			_add_vfx() 
			
			collider.call("take_damage", damage)
			
			
			if is_piercing:
				shape_cast.add_exception_rid(collider_rid)
				var pass_through_distance := minf(1.0, remaining_distance)
				global_position += direction * pass_through_distance
				remaining_distance -= pass_through_distance
				continue

			#await bullet_collision_vfx.emitting
			queue_free()
			return

		if remaining_bounces > 0 and collision_normal != Vector2.ZERO:
			_add_vfx() 
			remaining_bounces -= 1
			direction = direction.bounce(collision_normal).normalized()
			global_rotation = direction.angle()
			global_position += collision_normal * 0.5
			bounced.emit(global_position, collision_normal)

			# Resume on the next physics tick. Recasting immediately from the
			# contact point can report the same wall again and destroy a bullet
			# that has just consumed its only bounce.
			return

		_add_vfx() 
		queue_free()
		return

	# Avoid keeping a projectile alive inside an unresolved stack of colliders.
	queue_free()


func _apply_visuals() -> void:
	sprite.material = bullet_resource.create_visual_material()
	sprite.modulate = Color.WHITE if sprite.material != null else bullet_resource.bullet_color
	if bullet_resource.bullet_textures.is_empty():
		sprite.texture = null
		return

	sprite.texture = bullet_resource.bullet_textures[0]
	if sprite.texture != null:
		var source_size := sprite.texture.get_size()
		if source_size.x > 0.0 and source_size.y > 0.0:
			sprite.scale = bullet_resource.bullet_texture_size / source_size


func _apply_collision_shape() -> void:
	var rectangle := RectangleShape2D.new()
	rectangle.size = bullet_resource.bullet_collision_shape_size
	shape_cast.shape = rectangle
	shape_cast.position = bullet_resource.bullet_collision_shape_offset


func _update_texture(delta: float) -> void:
	if bullet_resource.bullet_textures.size() < 2:
		return
	if bullet_resource.bullet_change_texture_time <= 0.0:
		return

	texture_elapsed += delta
	if texture_elapsed < bullet_resource.bullet_change_texture_time:
		return

	texture_elapsed = fmod(texture_elapsed, bullet_resource.bullet_change_texture_time)
	texture_index = (texture_index + 1) % bullet_resource.bullet_textures.size()
	sprite.texture = bullet_resource.bullet_textures[texture_index]
	

func _add_vfx() -> void:
	var effect = bullet_collision_vfx.instantiate()
	
	get_tree().current_scene.add_child(effect)
	effect.global_position = global_position
	
