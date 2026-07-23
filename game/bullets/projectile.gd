class_name TacticalProjectile
extends Node2D

signal enemy_hit(enemy: Node)
signal terrain_destroyed(wall: DestructibleWall)
signal resolved(projectile: TacticalProjectile)

var definition: BulletDefinition
var direction := Vector2.RIGHT
var remaining_lifetime := 0.0
var bounces_left := 0
var _resolved := false
var _hit_rids: Array[RID] = []

func _ready() -> void:
	add_to_group("tactical_projectile")

func configure(bullet: BulletDefinition, start_position: Vector2, aim_direction: Vector2) -> void:
	definition = bullet
	global_position = start_position
	direction = aim_direction.normalized()
	rotation = direction.angle()
	remaining_lifetime = definition.lifetime
	bounces_left = definition.max_bounces
	($Visual as Polygon2D).color = definition.color

func _physics_process(delta: float) -> void:
	if _resolved or definition == null:
		return
	remaining_lifetime -= delta
	if remaining_lifetime <= 0.0:
		resolve()
		return
	var distance := definition.speed * delta
	var space := get_world_2d().direct_space_state
	var safety := 0
	while distance > 0.01 and safety < 12 and not _resolved:
		safety += 1
		var target := global_position + direction * distance
		var query := PhysicsRayQueryParameters2D.create(global_position, target, 1 | 4)
		query.exclude = _hit_rids
		var hit := space.intersect_ray(query)
		if hit.is_empty():
			global_position = target
			break
		var traveled := global_position.distance_to(hit.position)
		global_position = hit.position
		distance = maxf(0.0, distance - traveled)
		var collider: Object = hit.collider
		if collider is SightEnemy:
			collider.receive_bullet(definition)
			enemy_hit.emit(collider)
			if definition.pierces_enemies and not collider.armored:
				_hit_rids.append(hit.rid)
				global_position += direction * 2.0
				continue
			resolve()
		elif collider is DestructibleWall and definition.alters_terrain:
			collider.destroy()
			terrain_destroyed.emit(collider)
			resolve()
		elif bounces_left > 0:
			bounces_left -= 1
			direction = direction.bounce(hit.normal).normalized()
			rotation = direction.angle()
			global_position += direction * 2.0
		else:
			resolve()

func resolve() -> void:
	if _resolved:
		return
	_resolved = true
	resolved.emit(self)
	queue_free()

