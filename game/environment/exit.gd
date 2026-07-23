class_name ExitDoor
extends Node2D

signal entered

var unlocked := false

func _ready() -> void:
	$Trigger.body_entered.connect(_on_body_entered)
	_update_visual()

func set_unlocked(value: bool) -> void:
	if unlocked == value:
		return
	unlocked = value
	$Barrier.collision_layer = 0 if unlocked else 1
	$Barrier/CollisionShape2D.set_deferred("disabled", unlocked)
	_update_visual()

func _on_body_entered(body: Node2D) -> void:
	if unlocked and body.is_in_group("player"):
		entered.emit()

func _update_visual() -> void:
	$Visual.color = Color("65e68a") if unlocked else Color("9d4141")

