class_name LevelDefinition extends Resource

## Typed authored-room contract shared by GameState, CampaignLevel, and tests.
@export_range(1, 6) var index := 1
@export var title := ""
@export_multiline var brief := ""
@export var spawn := Vector2i(2, 2)
@export var exit := Vector2i(37, 19)
@export var bullet_paths: Array[String] = []
@export var walls: Array[Rect2i] = []
@export var enemies: Array[Resource] = []
@export_range(1, 6) var minimum_solution_shots := 1

## Rejects malformed catalog entries before a room is constructed.
func is_valid() -> bool:
	return index >= 1 and index <= 6 and not title.is_empty() \
		and bullet_paths.size() == 6 and not enemies.is_empty() \
		and minimum_solution_shots >= 1 and minimum_solution_shots <= 6
