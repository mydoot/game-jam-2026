class_name Weapon
extends Node2D

@export var damage: int = 1
@export var cooldown: float = 0.5

@onready var anim_player = $AnimationPlayer
@onready var hitbox = $Hitbox
@onready var vfx = $VFX

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
	player_damage_data = DamageData.new()
	player_damage_data.damage = 1
	player_damage_data.is_from_player = true
	player_damage_data.is_ricoshot = false
	player_damage_data.is_piercing = false
	
	
	if bullet_resource:
		bullet_data = bullet_resource.set_up_bullet_data()
		bullet_data.bullets_custom_data = player_damage_data

# Called every frame. 'delta' is the elapsed time since the previous frame.
	
	
func shoot() -> void:
	if bullet_data:
		bullet_data.transforms = grab_marker_transforms()
		if bullet_data.transforms:
			BulletFactory.bullet_factory.spawn_directional_bullets(bullet_data)
		else:
			push_warning("bullet_data has no DirectionalBulletsData2D object.")

func grab_marker_transforms() -> Array[Transform2D]:
	var all_markers : Array[Transform2D]
	
	for marker : Marker2D in marker_container.get_children():
		all_markers.push_back(marker.global_transform)
		
	return all_markers	
