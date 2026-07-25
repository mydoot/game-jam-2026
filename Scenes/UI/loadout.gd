extends Panel

@onready var planning: Node2D = $"../../.."

@onready var loadout_grid: GridContainer = $"Loadout Grid"

@onready var available_shots_grid: GridContainer = $"../Available Bullets/Available Shots Grid"

@onready var start_button: Button = $"../Start Button"

var list_of_bullets: Array[Resource] = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_bullets_as_available_bullets()


func load_bullets_into_list() -> void:
	for slot in loadout_grid.get_children():
		var item: Slot = slot
		list_of_bullets.append(item.bullet)

func pass_bullet_list() -> void:
	GlobalVariables.bullet_loadout.assign(list_of_bullets)
	#print(GlobalVariables.bullet_loadout)
	
func add_bullets_as_available_bullets() -> void:
	for slot in available_shots_grid.get_children():
		var slot_data: Slot = slot
		slot_data.bullet = planning.avail_bullets.pop_front()


func slots_are_full() -> bool:
	for slot in loadout_grid.get_children():
		var item: Slot = slot
		
		if not item.bullet:
			print("Not enough bullets loaded")
			return false
		
	return true
	
