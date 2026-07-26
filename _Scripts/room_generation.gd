class_name RoomGeneration
extends Node

## Prototype procedural room generator. It loads Room scenes, builds a connected
## occupancy grid, opens their RoomEntrance links, and positions an assigned
## Player. Current authored level scenes do not instantiate this prototype.
@export var map_size : int = 7
@export var rooms_to_generate : int = 12

var room_pos_offset : Vector2 = Vector2(640, 512) # 32 px per tile
var bigger_room_pos_offset : Vector2 = Vector2(704, 608)

var room_count : int = 0
var map : Array[bool]
var rooms : Array[Room] # Stores the actual room instances

var rooms_folder : String = "res://Scenes/Rooms/"
var room_dictionary : Dictionary = {}

# Drag your Player node here in the Inspector!
@export var player : CharacterBody2D 

## Loads room templates and builds the first procedural layout.
func _ready() -> void:
	_load_room_scenes()
	_generate()
	

## Loads every Room scene in rooms_folder into a name-to-PackedScene dictionary.
func _load_room_scenes() -> void:
	var dir = DirAccess.open(rooms_folder)
	
	if dir:
		for file in dir.get_files():
			var clean_name = file.replace(".remap", "") # Required for exported builds
			
			if clean_name.ends_with(".tscn"):
				var room_key = clean_name.get_basename() # e.g., "room_template" or "room2"
				var full_path = rooms_folder.path_join(clean_name)
				
				# Load and store the PackedScene
				room_dictionary[room_key] = ResourceLoader.load(full_path)
	else:
		push_error("Could not open rooms directory: " + rooms_folder)


## Regenerates the map, instantiates Room nodes, opens doors, and moves Player.
func _generate() -> void:
	for r in rooms:
		r.queue_free()
	rooms.clear()
	map.clear()
	map.resize(map_size * map_size)
	map.fill(false)
	
	var start_x : int = map_size / 2
	var start_y : int = map_size / 2
	
	_check_room(start_x, start_y, Vector2.ZERO)
	_instantiate_rooms()
	_open_connecting_doors()
	_spawn_player_in_center(start_x, start_y)


## Recursively marks connected cells until rooms_to_generate is reached.
func _check_room(x : int, y : int, incoming_direction : Vector2) -> void:
	if room_count >= rooms_to_generate: return
	if x < 0 or x >= map_size or y < 0 or y >= map_size: return
	if _get_map(x, y): return
	
	room_count += 1
	_set_map(x, y, true)
	
	var moves = [Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT]
	moves.shuffle()
	
	for move in moves:
		var new_x = x + int(move.x)
		var new_y = y + int(move.y)
		var threshold = 0.8
		if incoming_direction == Vector2.ZERO or move == incoming_direction:
			threshold = 0.2
		if randf() > threshold:
			_check_room(new_x, new_y, move)


## Instantiates a Room PackedScene for each occupied map cell.
func _instantiate_rooms() -> void:
	for x in range(map_size):
		for y in range(map_size):
			if not _get_map(x, y):
				continue
			
			var random_float = randf() * 100 # Percentage of bigger rooms
			var room
			if random_float <= 50:
				room = room_dictionary["bigger_room"].instantiate()
			else:
				room = room_dictionary["base_room"].instantiate()
			call_deferred("add_child", room)
			rooms.append(room)
			
			if random_float <= 10:
				room.global_position = Vector2(x, y) * bigger_room_pos_offset
			else:
				room.global_position = Vector2(x, y) * room_pos_offset
			
			
			# Give the room a name so we can find it easily if debugging
			room.name = "Room_%d_%d" % [x, y]


## Calls Room.open_entrance wherever the map contains an adjacent room.
func _open_connecting_doors() -> void:
	await get_tree().process_frame
	
	for x in range(map_size):
		for y in range(map_size):
			if not _get_map(x, y):
				continue
				
			var current_room = _find_room_at(x, y)
			if current_room == null: continue
			
			if _get_map(x, y - 1):
				current_room.open_entrance(Vector2.UP)
			
			if _get_map(x, y + 1):
				current_room.open_entrance(Vector2.DOWN)
				
			if _get_map(x - 1, y):
				current_room.open_entrance(Vector2.LEFT)
				
			if _get_map(x + 1, y):
				current_room.open_entrance(Vector2.RIGHT)


## Places the assigned Player in the map's starting Room.
func _spawn_player_in_center(start_x: int, start_y: int) -> void:
	var center_pos = Vector2(start_x, start_y) * room_pos_offset
	
	if player:
		player.global_position = center_pos
	else:
		push_warning("Player node not assigned in RoomGeneration Inspector.")


## Finds the instantiated room positioned at a map coordinate.
func _find_room_at(x: int, y: int) -> Room:
	var target_pos = Vector2(x, y) * room_pos_offset
	for r in rooms:
		if r.global_position.is_equal_approx(target_pos):
			return r
	return null


## Reads a map cell while treating out-of-bounds coordinates as empty.
func _get_map(x : int, y : int) -> bool:
	if x < 0 or x >= map_size or y < 0 or y >= map_size: return false
	return map[x + y * map_size]


## Writes a map cell after callers have validated coordinates.
func _set_map(x : int, y : int, value: bool) -> void:
	map[x + y * map_size] = value
