class_name Globals extends Node

## Shared runtime state used by scene scripts that need to coordinate across nodes.
## Keep direct variables available for existing scene scripts, but prefer the helper
## methods below when changing bullet/loadout state.
var bullet_loadout: Array[Resource] = []

var current_bullet: Resource

var spawn_point: Marker2D

var finish_point: Marker2D

## Replaces the current revolver queue with the six bullets chosen in planning.
func set_bullet_loadout(bullets: Array[Resource]) -> void:
	bullet_loadout.assign(bullets)
	current_bullet = bullet_loadout.front() if not bullet_loadout.is_empty() else null


## Clears any bullet state left over from a previous attempt or scene.
func clear_bullet_loadout() -> void:
	bullet_loadout.clear()
	current_bullet = null


## Returns true once the player has at least one bullet available to fire.
func has_loaded_bullets() -> bool:
	return not bullet_loadout.is_empty()


## Returns the bullet currently visible in the chamber/HUD.
func get_current_bullet() -> Resource:
	return current_bullet


## Consumes the current bullet and prepares the next one in the queue.
func advance_to_next_bullet() -> Resource:
	if not bullet_loadout.is_empty():
		bullet_loadout.pop_front()

	current_bullet = bullet_loadout.front() if not bullet_loadout.is_empty() else null
	return current_bullet
