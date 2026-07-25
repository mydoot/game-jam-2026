class_name Weapon extends Node2D

## Converts the chambered BasicBullet into a native PlayerProjectile and
## registers it with CampaignLevel so final-ammo outcomes are deterministic.
@export var damage: int = 1
@export var cooldown: float = 0.25
@export var marker_container: Node2D

signal attack_finished

var wielder: CharacterBody2D
var _cooldown_remaining := 0.0
const PROJECTILE_SCENE := preload("res://Scenes/Weapons/player_projectile.tscn")

## Counts down the firing cooldown without blocking player movement.
func _process(delta: float) -> void:
	_cooldown_remaining = maxf(_cooldown_remaining - delta, 0.0)

## Fires one projectile and consumes the chamber only after a valid spawn.
func shoot() -> bool:
	if _cooldown_remaining > 0.0:
		return false
	var bullet := GlobalVariables.get_current_bullet() as BasicBullet
	if bullet == null or marker_container == null or marker_container.get_child_count() == 0:
		return false
	var marker := marker_container.get_child(0) as Marker2D
	if marker == null:
		return false

	var projectile := PROJECTILE_SCENE.instantiate() as PlayerProjectile
	projectile.configure(bullet, marker.global_transform.x, damage, wielder)
	get_tree().current_scene.add_child(projectile)
	projectile.global_position = marker.global_position
	var level := get_tree().get_first_node_in_group("level")
	if level and level.has_method("register_projectile"):
		if not level.register_projectile(projectile):
			projectile.queue_free()
			return false
	GlobalVariables.advance_to_next_bullet()
	_cooldown_remaining = cooldown
	if has_node("/root/SfxBus"):
		SfxBus.play_world(&"shot", marker.global_position)
	_spawn_muzzle_flash(marker)
	if level and level.has_method("shake_camera"):
		level.shake_camera(2.0)
	attack_finished.emit()
	return true

## Draws a tiny warm muzzle wedge for one frame-length tween.
func _spawn_muzzle_flash(marker: Marker2D) -> void:
	var flash := Polygon2D.new()
	flash.polygon = PackedVector2Array([Vector2.ZERO, Vector2(18, -6), Vector2(18, 6)])
	flash.color = Color(1.0, 0.76, 0.24, 0.95)
	get_tree().current_scene.add_child(flash)
	flash.global_transform = marker.global_transform
	var tween := flash.create_tween()
	tween.tween_property(flash, "modulate:a", 0.0, 0.08)
	tween.finished.connect(flash.queue_free)
