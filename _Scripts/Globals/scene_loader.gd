extends Node

## Serialized threaded scene-transition service. It rejects duplicate/invalid
## requests, swaps while fully covered, and resets its guard after every outcome.
signal progress_changed(progress: float)
signal load_finished(scene_path: String)

var loading_screen: PackedScene = preload("res://Scenes/UI/loading_screen.tscn")
var scene_path := ""
var progress: Array = []
var use_sub_threads := false
var active_loading_screen: CanvasLayer
var is_loading := false

## Keeps polling disabled and transitions responsive if a caller was paused.
func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	set_process(false)

## Starts one covered request and immediately reports acceptance to callers.
func load_scene(requested_path: String) -> bool:
	if requested_path.is_empty() or not ResourceLoader.exists(requested_path, "PackedScene"):
		return false
	if is_loading:
		return false
	is_loading = true
	scene_path = requested_path
	progress.clear()
	active_loading_screen = loading_screen.instantiate()
	add_child(active_loading_screen)
	progress_changed.connect(active_loading_screen._on_progress_changed)
	active_loading_screen.loading_screen_ready.connect(_on_overlay_covered, CONNECT_ONE_SHOT)
	return true

## Requests the resource only after the entrance animation fully covers the view.
func _on_overlay_covered() -> void:
	var state := ResourceLoader.load_threaded_request(scene_path, "", use_sub_threads)
	if state == OK:
		set_process(true)
	else:
		_cancel_load("Failed to request threaded load for scene: %s" % scene_path)

## Polls progress and installs a completed PackedScene while still covered.
func _process(_delta: float) -> void:
	var status := ResourceLoader.load_threaded_get_status(scene_path, progress)
	progress_changed.emit(float(progress[0]) if not progress.is_empty() else 0.0)
	match status:
		ResourceLoader.THREAD_LOAD_INVALID_RESOURCE, ResourceLoader.THREAD_LOAD_FAILED:
			_cancel_load("Failed to load scene: %s" % scene_path)
		ResourceLoader.THREAD_LOAD_LOADED:
			set_process(false)
			var packed := ResourceLoader.load_threaded_get(scene_path) as PackedScene
			if packed == null:
				_cancel_load("Loaded resource is not a PackedScene: %s" % scene_path)
				return
			var requested_path := scene_path
			var error := get_tree().change_scene_to_packed(packed)
			if error != OK:
				_cancel_load("Failed to change scene: %s" % scene_path)
				return
			await get_tree().process_frame
			load_finished.emit(requested_path)
			await _reveal_overlay()
			_reset()

## Reveals either the new scene or the unchanged scene after failure.
func _reveal_overlay() -> void:
	if active_loading_screen and is_instance_valid(active_loading_screen):
		await active_loading_screen._on_load_finished()

## Cancels safely and releases the request guard after the overlay exits.
func _cancel_load(message: String) -> void:
	set_process(false)
	push_warning(message)
	await _reveal_overlay()
	_reset()

## Disconnects transient signal state and clears the serialized request.
func _reset() -> void:
	if active_loading_screen and progress_changed.is_connected(active_loading_screen._on_progress_changed):
		progress_changed.disconnect(active_loading_screen._on_progress_changed)
	active_loading_screen = null
	scene_path = ""
	progress.clear()
	is_loading = false
