extends Node2D

@onready var loadout: Panel = $Canvas/LoadoutMenu/Loadout

@onready var loadout_menu: Control = $Canvas/LoadoutMenu

const player_scene = preload("res://Scenes/player.tscn")

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
