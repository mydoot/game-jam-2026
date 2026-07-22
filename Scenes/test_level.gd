extends Node2D


func _ready() -> void:
	BulletFactory.bullet_factory = $BulletFactory2D
