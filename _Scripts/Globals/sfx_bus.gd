extends Node

## Shared sound service for menus, weapons, enemies, exits, and projectiles.
const EFFECTS := {
	&"click": "res://Assets/Audio/click.wav",
	&"shot": "res://Assets/Audio/shot.wav",
	&"impact": "res://Assets/Audio/impact.wav",
	&"ricochet": "res://Assets/Audio/ricochet.wav",
	&"shield": "res://Assets/Audio/shield.wav",
	&"alert": "res://Assets/Audio/alert.wav",
	&"laser": "res://Assets/Audio/laser.wav",
	&"enemy_down": "res://Assets/Audio/enemy_down.wav",
	&"exit": "res://Assets/Audio/exit.wav",
	&"failure": "res://Assets/Audio/failure.wav",
	&"victory": "res://Assets/Audio/victory.wav",
}
var _streams: Dictionary = {}

## Loads deterministic effects once; headless validation remains silent.
func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	if DisplayServer.get_name() == "headless":
		return
	for effect in EFFECTS:
		var path: String = EFFECTS[effect]
		if ResourceLoader.exists(path):
			_streams[effect] = load(path)

## Plays a non-positional interface sound.
func play_ui(effect: StringName) -> void:
	if not _streams.has(effect):
		return
	var player := AudioStreamPlayer.new()
	player.add_to_group("sfx_player")
	player.stream = _streams[effect]
	player.bus = &"SFX"
	add_child(player)
	player.finished.connect(player.queue_free)
	player.play()

## Plays a positional world sound.
func play_world(effect: StringName, position: Vector2) -> void:
	if not _streams.has(effect):
		return
	var player := AudioStreamPlayer2D.new()
	player.add_to_group("sfx_player")
	player.stream = _streams[effect]
	player.bus = &"SFX"
	player.global_position = position
	player.max_distance = 900.0
	add_child(player)
	player.finished.connect(player.queue_free)
	player.play()

## Stops active effects and releases cached streams for clean shutdown.
func stop_all() -> void:
	for player in get_tree().get_nodes_in_group("sfx_player"):
		player.queue_free()
	_streams.clear()
