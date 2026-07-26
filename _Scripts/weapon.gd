class_name Weapon
extends Node2D

## Player weapon controller. It turns chambered BasicBullet resources into
## native Godot projectile nodes and signals Player so HUD can advance.
@export var damage: int = 1
@export var cooldown: float = 0.5

@export_group("For Bullets")
@export var bullet_scene: PackedScene = preload("res://Scenes/Weapons/Bullet.tscn")
@export var marker_container: Node2D

var bullet_resource: BasicBullet

signal attack_finished
signal dealt_damage

var is_attacking: bool = false

var wielder: CharacterBody2D

## Prepares the first chambered bullet.
func _ready() -> void:
	_prepare_current_bullet()


## Spawns native projectiles, advances GlobalVariables, and notifies Player.
func shoot() -> void:
	if bullet_resource == null:
		push_warning("Cannot shoot without a prepared bullet resource.")
		return

	if marker_container == null or marker_container.get_child_count() == 0:
		push_warning("Weapon has no firing markers configured.")
		return
	if bullet_scene == null:
		push_warning("Weapon has no native bullet scene configured.")
		return

	var projectile_parent := get_tree().current_scene
	if projectile_parent == null:
		projectile_parent = get_parent()

	for marker: Marker2D in marker_container.get_children():
		for _bullet_index in range(maxi(bullet_resource.amount_of_bullets, 1)):
			var projectile := bullet_scene.instantiate() as PlayerBullet
			if projectile == null:
				push_warning("Configured bullet scene does not use PlayerBullet.")
				continue

			projectile_parent.add_child(projectile)
			# Copying the full marker transform also copies Player's 0.35 scale
			# and mirrored aim scale, which shortens ShapeCast2D's sweep.
			projectile.global_position = marker.global_position
			projectile.global_scale = Vector2.ONE
			projectile.configure(
				bullet_resource,
				damage,
				marker.global_transform.x.normalized(),
				wielder
			)

	GlobalVariables.advance_to_next_bullet()
	_prepare_current_bullet()
	attack_finished.emit()


## Reads the resource shared by the planning loadout and HUD.
func _prepare_current_bullet() -> void:
	bullet_resource = GlobalVariables.get_current_bullet() as BasicBullet
