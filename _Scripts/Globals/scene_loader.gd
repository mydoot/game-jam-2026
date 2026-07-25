extends Node

## Autoload that shows the loading screen and performs threaded scene changes.

signal progress_changed(progress)
signal load_finished

var loading_screen: PackedScene = preload("uid://dflfrr7bqx2vs") # loading_screen.tscn UID
var loaded_resource: PackedScene
var scene_path: String
var progress: Array = []
var use_sub_threads: bool = false
var active_loading_screen: CanvasLayer
var is_loading: bool = false

func _ready() -> void:
	set_process(false)
	

## Creates the loading screen, waits for its entrance animation, then starts load.
func load_scene(_scene_path: String) -> void:
	if _scene_path.is_empty():
		push_warning("Cannot load an empty scene path.")
		return
	if is_loading:
		return

	is_loading = true
	scene_path = _scene_path
	progress.clear()
	
	active_loading_screen = loading_screen.instantiate()
	add_child(active_loading_screen)
	progress_changed.connect(active_loading_screen._on_progress_changed)
	
	await active_loading_screen.loading_screen_ready
	
	start_load()


## Requests threaded loading for the pending scene path.
func start_load() -> void:
	var state = ResourceLoader.load_threaded_request(scene_path, "", use_sub_threads)
	if state == OK:
		set_process(true)
	else:
		_cancel_load("Failed to request threaded load for scene: " + scene_path)


## Polls load progress and changes scene once the loading screen can exit.
func _process(_delta: float) -> void:
	var load_status = ResourceLoader.load_threaded_get_status(scene_path, progress)
	var load_progress: float = float(progress[0]) if not progress.is_empty() else 0.0
	progress_changed.emit(load_progress)
	match load_status:
		ResourceLoader.THREAD_LOAD_INVALID_RESOURCE, ResourceLoader.THREAD_LOAD_FAILED:
			_cancel_load("Failed to load scene: " + scene_path)
		ResourceLoader.THREAD_LOAD_LOADED:
			set_process(false)
			loaded_resource = ResourceLoader.load_threaded_get(scene_path)
			if loaded_resource == null:
				_cancel_load("Loaded resource is not a PackedScene: " + scene_path)
				return

			var change_error := get_tree().change_scene_to_packed(loaded_resource)
			if change_error != OK:
				_cancel_load("Failed to change scene: " + scene_path)
				return

			load_finished.emit()
			await get_tree().process_frame
			if active_loading_screen:
				await active_loading_screen._on_load_finished()
				active_loading_screen = null
			is_loading = false


## Restores the current scene if a threaded load cannot be completed.
func _cancel_load(message: String) -> void:
	set_process(false)
	push_warning(message)
	if active_loading_screen:
		await active_loading_screen._on_load_finished()
		active_loading_screen = null
	is_loading = false
