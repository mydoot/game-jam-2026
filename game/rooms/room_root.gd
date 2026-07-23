class_name RoomRoot
extends Node2D

@export var room_size := Vector2(960, 600)

@onready var player_spawn: Marker2D = $PlayerSpawn
@onready var exit_door: ExitDoor = $Exit
@onready var enemies: Node2D = $Enemies

func configure_enemies(player: RevolverPlayer) -> Array[SightEnemy]:
	var result: Array[SightEnemy] = []
	for child in enemies.get_children():
		if child is SightEnemy:
			child.set_player(player)
			result.append(child)
	return result

func get_center() -> Vector2:
	return room_size * 0.5

