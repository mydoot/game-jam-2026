class_name RoomEntrance
extends Node2D

## Directional doorway discovered and controlled by its parent Room. Generation
## asks Room to open entrances that have neighboring rooms.
@export var direction : Vector2 

@onready var barrier = $Barrier

## Starts every generated doorway closed until RoomGeneration opens valid links.
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
