class_name LevelDefinition
extends Resource

## Designer-owned campaign metadata and its editor-authored room scene.

@export var level_id := ""
@export var title := ""
@export_multiline var tutorial := ""
@export_multiline var description := ""
@export var room_scene: PackedScene
@export var supplied_rounds: Array[BulletDefinition] = []
@export var unlock_reward: BulletDefinition

func is_valid_definition() -> bool:
	return (
		not level_id.is_empty()
		and not title.is_empty()
		and room_scene != null
		and supplied_rounds.size() == 6
		and not supplied_rounds.has(null)
	)

