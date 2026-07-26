extends Panel

## Manages the planning screen's selected and available Slot nodes. Planning
## calls this script to validate the revolver and copy its order to
## GlobalVariables before spawning Player.
@onready var planning: Node2D = $"../../.."

@onready var loadout_grid: TextureRect = $"Loadout Grid"

@onready var available_shots_grid: TextureRect = $"../Available Bullets/Available Shots Grid"

@onready var start_button: Button = $"../Start Button"

var list_of_bullets: Array[Resource] = []

## Populates the available-shot slots from Planning's level-specific bullet list.
func _ready() -> void:
	add_bullets_as_available_bullets()


## Reads the six selected Slot resources from left to right into a temporary list.
func load_bullets_into_list() -> void:
	list_of_bullets.clear()
	for slot in loadout_grid.get_children():
		var item: Slot = slot
		list_of_bullets.append(item.bullet)


## Gives the ordered list to GlobalVariables, which Weapon consumes during combat.
func pass_bullet_list() -> void:
	GlobalVariables.set_bullet_loadout(list_of_bullets)
	

## Fills available Slot nodes without mutating Planning's exported level data.
func add_bullets_as_available_bullets() -> void:
	var bullet_index := 0
	for slot in available_shots_grid.get_children():
		var slot_data: Slot = slot
		slot_data.bullet = planning.avail_bullets[bullet_index] if bullet_index < planning.avail_bullets.size() else null
		slot_data.update_ui()
		bullet_index += 1


## Lets Planning verify that every revolver Slot contains a bullet before combat.
func slots_are_full() -> bool:
	for slot in loadout_grid.get_children():
		var item: Slot = slot
		
		if not item.bullet:
			push_warning("Not enough bullets loaded.")
			return false
		
	return true
	
