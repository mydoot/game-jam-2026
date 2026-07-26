class_name PlayerProjectile extends CharacterBody2D

## Native projectile configured by Weapon and tracked by CampaignLevel.
signal resolved(projectile: PlayerProjectile)
signal bounced(projectile: PlayerProjectile)

var definition: BasicBullet
var damage := 1
var direction := Vector2.RIGHT
var lifetime := 4.0
var bounces_left := 0
var has_bounced := false
var _resolved := false
var _hit_enemies: Dictionary = {}
@onready var sprite: Sprite2D = $Sprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

## Copies shot data and excludes its owner.
func configure(bullet: BasicBullet, shot_direction: Vector2, shot_damage: int, owner_body: PhysicsBody2D) -> void:
	definition = bullet
	direction = shot_direction.normalized()
	damage = shot_damage
	lifetime = bullet.lifetime
	bounces_left = bullet.bounce_count
	if owner_body:
		add_collision_exception_with(owner_body)

## Applies the ammunition's texture and collision radius.
func _ready() -> void:
	if definition:
		sprite.texture = definition.get_icon()
		sprite.modulate = definition.projectile_tint
		var size := sprite.texture.get_size()
		var edge := maxf(size.x, size.y)
		sprite.scale = Vector2.ONE * (definition.visual_size / edge if edge > 0.0 else 1.0)
		sprite.rotation = direction.angle() + PI * 0.5
		var circle := collision_shape.shape as CircleShape2D
		if circle:
			circle.radius = definition.collision_radius

## Moves deterministically and resolves at its lifetime limit.
func _physics_process(delta: float) -> void:
	if _resolved or definition == null:
		return
	lifetime -= delta
	if lifetime <= 0.0:
		_resolve()
		return
	var collision := move_and_collide(direction * definition.speed * delta)
	if collision:
		_handle_collision(collision)

## Implements stopping, piercing, and exactly one ricochet.
func _handle_collision(collision: KinematicCollision2D) -> void:
	var enemy := collision.get_collider() as Enemy
	if enemy:
		var enemy_id := enemy.get_instance_id()
		if not _hit_enemies.has(enemy_id):
			_hit_enemies[enemy_id] = true
			enemy.receive_projectile(definition.bullet_type, has_bounced, damage)
			_spawn_impact(definition.projectile_tint)
			if definition.bullet_type == BasicBullet.BulletType.PIERCING:
				add_collision_exception_with(enemy)
				global_position += direction * 3.0
				return
		_resolve()
		return
	if definition.bullet_type == BasicBullet.BulletType.RICOCHET and bounces_left > 0:
		direction = direction.bounce(collision.get_normal()).normalized()
		bounces_left -= 1
		has_bounced = true
		sprite.rotation = direction.angle() + PI * 0.5
		global_position += collision.get_normal() * 2.0
		bounced.emit(self)
		_spawn_impact(Color(0.3, 0.9, 1.0))
		SfxBus.play_world(&"ricochet", global_position)
		return
	SfxBus.play_world(&"impact", global_position)
	_spawn_impact(Color(0.9, 0.75, 0.4))
	_resolve()

## Creates a short impact ring that survives projectile removal.
func _spawn_impact(color: Color) -> void:
	if not is_inside_tree() or DisplayServer.get_name() == "headless":
		return
	var ring := Line2D.new()
	ring.width = 2.0
	ring.default_color = color
	ring.closed = true
	for index in 12:
		ring.add_point(Vector2.RIGHT.rotated(TAU * float(index) / 12.0) * 5.0)
	get_tree().current_scene.add_child(ring)
	ring.global_position = global_position
	var tween := ring.create_tween().set_parallel(true)
	tween.tween_property(ring, "scale", Vector2(2.2, 2.2), 0.16)
	tween.tween_property(ring, "modulate:a", 0.0, 0.16)
	tween.chain().tween_callback(ring.queue_free)

## Emits resolution once and queues removal.
func _resolve() -> void:
	if _resolved:
		return
	_resolved = true
	resolved.emit(self)
	queue_free()
