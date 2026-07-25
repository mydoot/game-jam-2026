extends Panel

## Manages the planning-screen bullet slots and transfers the chosen order into
## global runtime state when the level starts.
@onready var planning: Node2D = $"../../.."

@onready var loadout_grid: GridContainer = $"Loadout Grid"

@onready var available_shots_grid: GridContainer = $"../Available Bullets/Available Shots Grid"

@onready var start_button: Button = $"../Start Button"

var list_of_bullets: Array[Resource] = []

func _ready() -> void:
	add_bullets_as_available_bullets()


## Reads the six selected loadout slots from left to right.
func load_bullets_into_list() -> void:
	list_of_bullets.clear()
	for slot in loadout_grid.get_children():
		var item: Slot = slot
		list_of_bullets.append(item.bullet)


## Stores the selected loadout for the weapon to consume during combat.
func pass_bullet_list() -> void:
	GlobalVariables.set_bullet_loadout(list_of_bullets)
	

## Fills the available-bullets panel without mutating the exported level data.
func add_bullets_as_available_bullets() -> void:
	var bullet_index := 0
	for slot in available_shots_grid.get_children():
		var slot_data: Slot = slot
		slot_data.bullet = planning.avail_bullets[bullet_index] if bullet_index < planning.avail_bullets.size() else null
		slot_data.update_ui()
		bullet_index += 1


## Verifies that every revolver slot has a bullet before combat starts.
func slots_are_full() -> bool:
	for slot in loadout_grid.get_children():
		var item: Slot = slot
		
		if not item.bullet:
			push_warning("Not enough bullets loaded.")
			return false
		
	return true
	
