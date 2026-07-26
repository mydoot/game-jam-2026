extends Node2D

## Authored level root. It registers SpawnPoint for Planning and delegates a
## cleared exit transition to SceneLoader.
## This needs to be the UID of a scene
@export var next_level: StringName = &""

## Registers this level's SpawnPoint for Planning.
func _ready() -> void:
	GlobalVariables.spawn_point = $SpawnPoint


## Loads next_level through SceneLoader when Player reaches the connected finish
## Area2D after every node in the enemy group has been removed.
func _on_finish_point_body_entered(body: Node2D) -> void:
	if not (body is Player):
		return
	#if not get_tree().get_nodes_in_group("enemy").is_empty():
		#return

	if next_level != &"":
		SceneLoader.load_scene(String(next_level))
	else:
		push_warning("There is no scene UID in next_level, cannot change scene.")
		return
