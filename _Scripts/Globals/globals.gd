class_name Globals extends Node

## Autoload state shared across Planning, Loadout, Weapon, HUD, and level roots.
## It owns the ordered revolver queue and the current level's spawn/finish markers.
var bullet_loadout: Array[Resource] = []

var current_bullet: Resource

var spawn_point: Marker2D

var finish_point: Marker2D

## Receives the six ordered BasicBullet resources from Loadout.
func set_bullet_loadout(bullets: Array[Resource]) -> void:
	bullet_loadout.assign(bullets)
	current_bullet = bullet_loadout.front() if not bullet_loadout.is_empty() else null


## Lets Planning clear bullet state left by a previous attempt or scene.
func clear_bullet_loadout() -> void:
	bullet_loadout.clear()
	current_bullet = null


## Lets Player verify that Weapon has a chambered resource before spending ammo.
func has_loaded_bullets() -> bool:
	return not bullet_loadout.is_empty()


## Returns the BasicBullet currently used by Weapon and displayed by HUD.
func get_current_bullet() -> Resource:
	return current_bullet


## Called by Weapon after firing to consume the chamber and expose the next round.
func advance_to_next_bullet() -> Resource:
	if not bullet_loadout.is_empty():
		bullet_loadout.pop_front()

	current_bullet = bullet_loadout.front() if not bullet_loadout.is_empty() else null
	return current_bullet
