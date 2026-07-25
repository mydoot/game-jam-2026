extends Node2D

## This needs to be the UID of a scene
@export var initial_scene: StringName = &""
@export var start_button: Button

func _ready() -> void:
	#if initial_scene
	pass


func _on_button_pressed() -> void:
	SceneLoader.load_scene(initial_scene)
