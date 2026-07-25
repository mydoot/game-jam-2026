class_name Room
extends Node2D

## Procedural room container. It indexes child RoomEntrance nodes by direction so
## RoomGeneration can open only connections backed by neighboring rooms.
var entrances : Dictionary = {}

## Discovers direct RoomEntrance children after the room enters the scene tree.
func _ready() -> void:
	for child in get_children():
		if child is RoomEntrance:
			entrances[child.direction] = child


## Opens the entrance assigned to the requested grid direction.
func open_entrance(direction : Vector2) -> void:
	if entrances.has(direction):
		entrances[direction].open()
