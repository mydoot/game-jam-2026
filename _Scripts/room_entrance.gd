class_name RoomEntrance
extends Node2D

## Doorway controlled by Room. The exported direction is assigned per instance.
@export var direction : Vector2 

@onready var barrier = $Barrier

func _ready() -> void:
	close()


## Disables collision and visuals so the player can pass through.
func open() -> void:
	barrier.process_mode = Node.PROCESS_MODE_DISABLED # Disables collision
	barrier.hide() # Hides the visual


## Restores collision and visuals so this doorway is blocked.
func close() -> void:
	barrier.process_mode = Node.PROCESS_MODE_INHERIT # Enables collision
	barrier.show()
