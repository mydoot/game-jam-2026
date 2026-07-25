extends Node2D

## Level root controller. Registers shared level references, routes bullet-hit
## damage, and handles finish-point scene transitions.
## This needs to be the UID of a scene
@export var next_level: StringName = &""

func _ready() -> void:
	BulletFactory.bullet_factory = $BulletFactory2D
	BulletFactory.bullet_factory.body_entered.connect(_on_bullet_hit)
	
	GlobalVariables.spawn_point = $SpawnPoint
	

## Receives BlastBullets2D hit callbacks and applies damage to the right target.
func _on_bullet_hit(hit_object: Object, _multimesh_bullets_instance: MultiMeshBullets2D, _bullet_index: int, data: Resource, _bullet_global_transform: Transform2D) -> void:
	var bullet_data: DamageData = data as DamageData
	
	if bullet_data != null:
		var enemy: Enemy = hit_object as Enemy
		var player: Player = hit_object as Player
		
		if enemy != null && bullet_data.is_from_player:
			enemy.take_damage(bullet_data.damage)
			
		if player != null && !bullet_data.is_from_player:
			player.take_damage(bullet_data.damage)


## Moves to the configured next level when the player reaches the exit.
func _on_finish_point_body_entered(body: Node2D) -> void:
	if not (body is Player):
		return
	if not get_tree().get_nodes_in_group("enemy").is_empty():
		return

	if next_level != &"":
		SceneLoader.load_scene(String(next_level))
	else:
		push_warning("There is no scene UID in next_level, cannot change scene.")
		return
