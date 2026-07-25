extends Node2D

@onready var loadout: Panel = $Canvas/LoadoutMenu/Loadout

@onready var available_bullets: Panel = $"Canvas/LoadoutMenu/Available Bullets"

@onready var loadout_menu: Control = $Canvas/LoadoutMenu

## There should only be 6 bullet resource files in this array.
## This array is to add the bullets the player has to use to solve the level.
@export var avail_bullets: Array[Resource] = []

const player_scene = preload("res://Scenes/player.tscn")

func _ready() -> void:
	if avail_bullets.size() < 6:
		push_warning("avail_bullets requires 6 bullet resource files.")

func _on_start_button_pressed() -> void:
	if loadout == null:
		print("loadout menu is null")
		return
	
	if not loadout.slots_are_full(): 
		print("need bulls)")
		return
	
	loadout.load_bullets_into_list()
	loadout.pass_bullet_list()
	
	print("current size of loadout: ", GlobalVariables.bullet_loadout.size())
	print(GlobalVariables.bullet_loadout)
	
	var player = player_scene.instantiate()
	player.global_position = GlobalVariables.spawn_point.position
	
	get_parent().add_child(player)
	
	var cam = get_tree().get_first_node_in_group("camera")
	cam.target = player
	
	var tween = create_tween()
	tween.tween_property(loadout_menu, "position", Vector2(0, 450), 0.4).set_ease(Tween.EASE_IN).as_relative()


#func ready_available_bullets() -> void:
	#pass
