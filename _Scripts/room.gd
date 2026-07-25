class_name Room
extends Node2D

## Room container that caches directional entrances so generation can open doors.
var entrances : Dictionary = {}

func _ready() -> void:
	for child in get_children():
		if child is RoomEntrance:
			entrances[child.direction] = child


## Opens the entrance assigned to the requested grid direction.
func open_entrance(direction : Vector2) -> void:
	if entrances.has(direction):
		entrances[direction].open()
