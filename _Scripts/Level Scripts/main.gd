extends Node2D

## This needs to be the UID of a scene
@export var next_level: StringName = &""

func _ready() -> void:
	BulletFactory.bullet_factory = $BulletFactory2D
	BulletFactory.bullet_factory.body_entered.connect(_on_bullet_hit)
	
	#Globals.main_camera = $MainCamera
	GlobalVariables.spawn_point = $SpawnPoint
	

func _on_bullet_hit(hit_object: Object, multimesh_bullets_instance: MultiMeshBullets2D, bullet_index: int, data: Resource, bullet_global_transform: Transform2D) -> void:
	print("hit")
	var bullet_data: DamageData = data as DamageData
	
	if bullet_data != null:
		var enemy: Enemy = hit_object as Enemy
		var player: Player = hit_object as Player
		
		if enemy != null && bullet_data.is_from_player:
			enemy.take_damage(bullet_data.damage)
			
		if player != null && !bullet_data.is_from_player:
			player.take_damage(bullet_data.damage)


func _on_finish_point_body_entered(body: Node2D) -> void:
	if next_level:
		SceneLoader.load_scene(next_level)
	else:
		push_warning("There is no scene UID in next_level, cannot change scene.")
		return
