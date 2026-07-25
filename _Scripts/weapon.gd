class_name Weapon
extends Node2D

## Player weapon controller. It turns BasicBullet entries from GlobalVariables
## into BlastBullets2D data, spawns them through BulletFactoryGlobal, and signals
## Player so HUD can advance.
@export var damage: int = 1
@export var cooldown: float = 0.5

@export_group("For Bullets")
@export var bullet_resource : Resource
@export var marker_container : Node2D

var bullet_data : DirectionalBulletsData2D
var player_damage_data: DamageData

signal attack_finished
signal dealt_damage

var is_attacking: bool = false

var wielder: CharacterBody2D

## Prepares the first chambered bullet and its matching damage metadata.
func _ready() -> void:
	_prepare_current_bullet()


## Fires the chambered BasicBullet through BulletFactory, advances
## GlobalVariables, prepares the next round, and notifies Player.
func shoot() -> void:
	if bullet_data == null:
		push_warning("Cannot shoot without prepared bullet data.")
		return

	var marker_transforms := grab_marker_transforms()
	if marker_transforms.is_empty():
		push_warning("Weapon has no firing markers configured.")
		return

	bullet_data.transforms = marker_transforms
	if BulletFactory.bullet_factory == null:
		push_warning("BulletFactory2D is not registered.")
		return

	BulletFactory.bullet_factory.spawn_directional_bullets(bullet_data)
	GlobalVariables.advance_to_next_bullet()
	_prepare_current_bullet()
	attack_finished.emit()


## Captures every Marker2D transform required by BlastBullets2D spawn data.
func grab_marker_transforms() -> Array[Transform2D]:
	var all_markers : Array[Transform2D]
	
	for marker : Marker2D in marker_container.get_children():
		all_markers.push_back(marker.global_transform)
		
	return all_markers	


## Creates per-shot DamageData consumed by the level's BulletFactory callback.
## A new resource is required for each round so preparing the next bullet cannot
## change the behavior of a projectile that is still traveling.
func _create_player_damage_data(pierces_enemies: bool) -> DamageData:
	var damage_data := DamageData.new()
	damage_data.damage = damage
	damage_data.is_from_player = true
	damage_data.is_ricoshot = false
	damage_data.is_piercing = pierces_enemies
	return damage_data


## Converts GlobalVariables' chambered BasicBullet into plugin-specific data and
## attaches the shared DamageData.
func _prepare_current_bullet() -> void:
	bullet_resource = GlobalVariables.get_current_bullet()
	if bullet_resource == null:
		bullet_data = null
		player_damage_data = null
		return

	player_damage_data = _create_player_damage_data(bullet_resource is PiercingBullet)
	bullet_data = bullet_resource.set_up_bullet_data()
	bullet_data.bullets_custom_data = player_damage_data
