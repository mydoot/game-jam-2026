class_name Weapon
extends Node2D

@export var damage: int = 1
@export var cooldown: float = 0.5
@export var knockback: float = 300.0
@export var mana_gain_on_hit: float = 1.0;

@onready var anim_player = $AnimationPlayer
@onready var hitbox = $Hitbox
@onready var vfx = $VFX

@export_group("For Bullets")
@export var bullet_resource : Resource
@export var marker_container : Node2D
var bullet_data : DirectionalBulletsData2D

signal attack_finished
signal dealt_damage
	
var is_attacking: bool = false

var wielder: CharacterBody2D

func _ready() -> void:
	if vfx.is_visible_in_tree():
		vfx.visible = false
		
	if bullet_resource:
		bullet_data = bullet_resource.set_up_bullet_data()

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
