class_name ShootingComponent extends Node

## Ranged attack component owned by Enemy. Enemy's Timer calls shoot; this script
## raycasts from its marker, calls Player.take_damage, and draws laser feedback.
@export_group("For Laser")
@export var marker_container : Node2D
@export var laser_damage: int = 1
@export var laser_range: float = 800.0
@export var laser_width: float = 5.0
@export var laser_duration: float = 0.12
@export_flags_2d_physics var laser_collision_mask: int = 5
@export var laser_color: Color = Color(1.0, 1.0, 1.0, 0.9)

@onready var enemy_gun_shot_sfx: AudioStreamPlayer2D = $"../EnemyGunShotSFX"

var is_attacking: bool = false

var wielder: CharacterBody2D

## Caches the parent Enemy body so attack rays can exclude their owner.
func _ready() -> void:
	wielder = get_parent() as CharacterBody2D


## Fires one laser from every Marker2D configured by the owning Enemy.
func shoot() -> void:
	enemy_gun_shot_sfx.play()
	for marker: Marker2D in marker_container.get_children():
		_fire_laser(marker)


## Raycasts against Player and terrain, damaging Player only when it is the first
## collision.
func _fire_laser(marker: Marker2D) -> void:
	var start_position := marker.global_position
	var end_position := start_position + marker.global_transform.x.normalized() * laser_range
	var query := PhysicsRayQueryParameters2D.create(start_position, end_position)
	query.collision_mask = laser_collision_mask
	query.collide_with_areas = true
	query.collide_with_bodies = true
	
	if wielder:
		query.exclude = [wielder.get_rid()]
	
	var result := marker.get_world_2d().direct_space_state.intersect_ray(query)
	
	if result:
		end_position = result["position"]
		var player := result["collider"] as Player
		if player:
			player.take_damage(laser_damage)
	
	_draw_laser(marker, end_position)


## Adds a temporary Line2D under the firing marker for the laser flash.
func _draw_laser(marker: Marker2D, end_position: Vector2) -> void:
	var laser := Line2D.new()
	laser.width = laser_width
	laser.default_color = laser_color
	laser.begin_cap_mode = Line2D.LINE_CAP_ROUND
	laser.end_cap_mode = Line2D.LINE_CAP_ROUND
	laser.points = PackedVector2Array([Vector2.ZERO, marker.to_local(end_position)])
	marker.add_child(laser)
	
	var tween := laser.create_tween()
	tween.tween_property(laser, "modulate:a", 0.0, laser_duration)
	tween.finished.connect(laser.queue_free)
