extends Node2D

@onready var player: Player = $".."

@export var animation_tree: AnimationTree

var last_facing_direction := Vector2(0, -1)

func _physics_process(delta: float) -> void:
	var idle = !player.velocity
	
	if !idle:
		last_facing_direction = player.velocity.normalized()
	
	animation_tree.set("parameters/Run/blend_position", last_facing_direction)
	animation_tree.set("parameters/Idle/blend_position", last_facing_direction)
	animation_tree.set("parameters/Shoot/blend_position", last_facing_direction)
