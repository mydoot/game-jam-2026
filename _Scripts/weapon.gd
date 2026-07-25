class_name Weapon
extends Node2D

## Player weapon controller. It converts the selected revolver loadout into
## BlastBullets2D data and spawns bullets from the configured marker container.
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

func _ready() -> void:
	player_damage_data = _create_player_damage_data()
	_prepare_current_bullet()


## Fires the currently chambered bullet and advances to the next bullet resource.
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


## Captures every firing marker transform so BlastBullets2D can spawn shots.
func grab_marker_transforms() -> Array[Transform2D]:
	var all_markers : Array[Transform2D]
	
	for marker : Marker2D in marker_container.get_children():
		all_markers.push_back(marker.global_transform)
		
	return all_markers	


## Creates damage metadata that gets attached to every player-fired bullet.
func _create_player_damage_data() -> DamageData:
	var damage_data := DamageData.new()
	damage_data.damage = damage
	damage_data.is_from_player = true
	damage_data.is_ricoshot = false
	damage_data.is_piercing = false
	return damage_data


## Builds plugin-specific bullet data for the bullet currently in the chamber.
func _prepare_current_bullet() -> void:
	bullet_resource = GlobalVariables.get_current_bullet()
	if bullet_resource == null:
		bullet_data = null
		return

	bullet_data = bullet_resource.set_up_bullet_data()
	bullet_data.bullets_custom_data = player_damage_data
