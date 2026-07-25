class_name Enemy extends CharacterBody2D

## Stationary laser sentry configured by a typed SentryPlacement. Its preview
## cone is ray-clipped by terrain, so displayed danger matches real line of sight.
signal died(enemy: Enemy)

@export var health := 1
@export var sight_range := 300.0
@export var cone_half_angle := 0.34
@export var fire_delay := 1.5
@export var requires_ricochet := false

@onready var sprite: Sprite2D = $Sprite2D
@onready var timer: Timer = $Timer
@onready var shooting_component: ShootingComponent = $ShootingComponent
@onready var firing_point: Marker2D = $MarkerContainer/FiringPoint
@onready var sight_cone: Polygon2D = $SightCone
@onready var shield_ring: Line2D = $ShieldRing

var combat_active := false
var target: Player
var _dying := false
var _visible_last_frame := false

## Initializes timing, shield readability, and the terrain-clipped preview.
func _ready() -> void:
	add_to_group("enemy")
	timer.wait_time = fire_delay
	timer.one_shot = true
	shield_ring.visible = requires_ricochet
	set_combat_active(false)
	call_deferred("_update_sight_visual", false)

## Updates visibility, acquisition color, and a cancellable charge timer.
func _physics_process(_delta: float) -> void:
	var visible := target != null and is_instance_valid(target) and _can_see(target)
	if visible and combat_active and not _visible_last_frame and has_node("/root/SfxBus"):
		SfxBus.play_world(&"alert", global_position)
	_visible_last_frame = visible
	if not combat_active or not visible:
		timer.stop()
	elif timer.is_stopped():
		timer.start()
	_update_sight_visual(visible)

## Assigns the current room's player without relying on global group searches.
func set_target(new_target: Player) -> void:
	target = new_target

## Enables or freezes the sentry at the planning/combat boundary.
func set_combat_active(active: bool) -> void:
	combat_active = active
	if not active and timer:
		timer.stop()

## Applies projectile rules and returns whether damage passed the shield.
func receive_projectile(bullet_type: BasicBullet.BulletType, bounced: bool, amount: int) -> bool:
	if _dying:
		return false
	if requires_ricochet and not (bullet_type == BasicBullet.BulletType.RICOCHET and bounced):
		_flash_shield()
		if has_node("/root/SfxBus"):
			SfxBus.play_world(&"shield", global_position)
		return false
	health -= amount
	if health <= 0:
		_dying = true
		_spawn_death_burst()
		if has_node("/root/SfxBus"):
			SfxBus.play_world(&"enemy_down", global_position)
		died.emit(self)
		queue_free()
		return true
	var tween := create_tween()
	tween.tween_property(sprite, "modulate", Color(1, 0.2, 0.2), 0.06)
	tween.tween_property(sprite, "modulate", Color.WHITE, 0.08)
	return true

## Compatibility damage entry used by older fixtures and non-projectile hazards.
func take_damage(amount: int) -> void:
	receive_projectile(BasicBullet.BulletType.NORMAL, false, amount)

## Fires only if the player remains visible after the full telegraph delay.
func _on_timer_timeout() -> void:
	if combat_active and target and _can_see(target):
		firing_point.global_rotation = global_position.direction_to(target.global_position).angle()
		shooting_component.shoot()
		if has_node("/root/SfxBus"):
			SfxBus.play_world(&"laser", global_position)

## Tests the configured cone and confirms terrain does not block the target ray.
func _can_see(body: Player) -> bool:
	var offset := body.global_position - global_position
	if offset.length() > sight_range:
		return false
	if absf(wrapf(offset.angle() - global_rotation, -PI, PI)) > cone_half_angle:
		return false
	var query := PhysicsRayQueryParameters2D.create(global_position, body.global_position, 5, [get_rid()])
	var hit := get_world_2d().direct_space_state.intersect_ray(query)
	return not hit.is_empty() and hit["collider"] == body

## Rebuilds a ray fan whose outer points stop at walls instead of crossing them.
func _update_sight_visual(target_visible: bool) -> void:
	if not is_inside_tree():
		return
	var points := PackedVector2Array([Vector2.ZERO])
	var segments := 18
	for index in range(segments + 1):
		var local_angle := lerpf(-cone_half_angle, cone_half_angle, float(index) / segments)
		var global_direction := Vector2.RIGHT.rotated(global_rotation + local_angle)
		var end := global_position + global_direction * sight_range
		var query := PhysicsRayQueryParameters2D.create(global_position, end, 4, [get_rid()])
		var hit := get_world_2d().direct_space_state.intersect_ray(query)
		points.append(to_local(hit["position"] if not hit.is_empty() else end))
	sight_cone.polygon = points
	if target_visible and combat_active:
		var charge := 1.0 - clampf(timer.time_left / maxf(fire_delay, 0.01), 0.0, 1.0)
		sight_cone.color = Color(1.0, lerpf(0.62, 0.12, charge), 0.08, lerpf(0.2, 0.38, charge))
	else:
		sight_cone.color = Color(0.95, 0.68, 0.15, 0.13)

## Pulses the blue ring when an invalid direct shot hits a shielded sentry.
func _flash_shield() -> void:
	if DisplayServer.get_name() == "headless":
		return
	var tween := create_tween()
	tween.tween_property(shield_ring, "width", 6.0, 0.06)
	tween.tween_property(shield_ring, "width", 2.0, 0.14)

## Leaves a restrained brass/red death flash after the sentry frees itself.
func _spawn_death_burst() -> void:
	if DisplayServer.get_name() == "headless":
		return
	var ring := Line2D.new()
	ring.width = 4.0
	ring.default_color = Color(1.0, 0.5, 0.18)
	ring.closed = true
	var points := PackedVector2Array()
	for index in 14:
		points.append(Vector2.RIGHT.rotated(TAU * float(index) / 14.0) * 12.0)
	ring.points = points
	get_tree().current_scene.add_child(ring)
	ring.global_position = global_position
	var tween := ring.create_tween().set_parallel(true)
	tween.tween_property(ring, "scale", Vector2(2.5, 2.5), 0.22)
	tween.tween_property(ring, "modulate:a", 0.0, 0.22)
	tween.chain().tween_callback(ring.queue_free)
