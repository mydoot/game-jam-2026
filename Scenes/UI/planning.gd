extends Node2D

## Coordinates the planning-to-combat handoff. It uses Loadout to store the
## selected order in GlobalVariables, spawns Player at the level SpawnPoint, and
## gives MainCamera its target.
@onready var loadout: Panel = $Canvas/LoadoutMenu/Loadout

@onready var available_bullets: Panel = $"Canvas/LoadoutMenu/Available Bullets"

@onready var loadout_menu: Control = $Canvas/LoadoutMenu

@onready var hint_label: Label = $Canvas/Label

## There should only be 6 bullet resource files in this array.
## This array is to add the bullets the player has to use to solve the level.
@export var avail_bullets: Array[Resource] = []

const player_scene = preload("res://Scenes/player.tscn")

var is_menu_hidden: bool = false
var combat_started: bool = false
var menu_visible_position: Vector2
var menu_tween: Tween

## Clears state left by the previous attempt and records the menu's authored
## position so repeated hide/show tweens always return to the same location.
func _ready() -> void:
	GlobalVariables.clear_bullet_loadout()
	menu_visible_position = loadout_menu.position
	if avail_bullets.size() < 6:
		push_warning("avail_bullets requires 6 bullet resource files.")
		
## Listens for the preview-menu toggle only until combat has started.
func _process(_delta: float) -> void:
	if not combat_started and Input.is_action_just_pressed("hide_menu"):
		hide_loadout_menu()


## Validates Loadout, transfers its bullets through GlobalVariables, spawns one
## Player, connects MainCamera to it, and dismisses the planning interface.
func _on_start_button_pressed() -> void:
	if combat_started:
		return
	if loadout == null:
		push_warning("Loadout menu is missing.")
		return
	
	if not loadout.slots_are_full(): 
		push_warning("Load all six bullets before starting.")
		return
	
	loadout.load_bullets_into_list()
	loadout.pass_bullet_list()
	combat_started = true
	loadout.start_button.disabled = true
	
	var player = player_scene.instantiate()
	if GlobalVariables.spawn_point:
		player.global_position = GlobalVariables.spawn_point.global_position
	else:
		push_warning("No spawn point registered; spawning player at the planning node position.")
		player.global_position = global_position
	
	get_parent().add_child(player)
	
	var cam = get_tree().get_first_node_in_group("camera")
	if cam:
		cam.target = player
	else:
		push_warning("No camera node found in the 'camera' group.")
	
	_move_menu(menu_visible_position + Vector2(0, 450), 0.4)
	
	hint_label.hide()


## Toggles the planning menu during preview so the authored room remains visible.
func hide_loadout_menu() -> void:
	if not is_menu_hidden:
		hint_label.text = "Press [E] to show menu"
		_move_menu(menu_visible_position + Vector2(0, 450), 0.15)
		is_menu_hidden = true
	else:
		hint_label.text = "Press [E] to hide menu"
		_move_menu(menu_visible_position, 0.15)
		is_menu_hidden = false


## Replaces any in-flight menu tween and moves toward an absolute target,
## preventing repeated E presses from accumulating relative offsets.
func _move_menu(target_position: Vector2, duration: float) -> void:
	if menu_tween and menu_tween.is_valid():
		menu_tween.kill()
	menu_tween = create_tween()
	menu_tween.tween_property(loadout_menu, "position", target_position, duration).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
