extends Node2D

var _bullet_hit_tracker: Dictionary = {}


func _ready() -> void:
	BulletFactory.bullet_factory = $BulletFactory2D
	BulletFactory.bullet_factory.body_entered.connect(_on_bullet_hit)
	

func _on_bullet_hit(hit_object: Object, multimesh_bullets_instance: MultiMeshBullets2D, bullet_index: int, data: Resource, bullet_global_transform: Transform2D) -> void:
	var bullet_data: DamageData = data as DamageData
	
	if bullet_data == null:
		return
	if not bullet_data.is_from_player:
		return
	
	var enemy: Enemy = hit_object as Enemy
	if enemy == null:
		return
	
	if bullet_data.is_piercing:
		if not _bullet_hit_tracker.has(bullet_index):
			_bullet_hit_tracker[bullet_index] = []
		if enemy in _bullet_hit_tracker[bullet_index]:
			return
		_bullet_hit_tracker[bullet_index].append(enemy)
	
	enemy.take_damage(bullet_data.damage)
