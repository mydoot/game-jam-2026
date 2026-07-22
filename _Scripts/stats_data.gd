class_name Stats
extends Node

@export_group("Helath (Hearts)")
@export var max_health: int = 1
@export var start_health: int = 1

@export_group("Bullets") 
@export var max_bullets: float = 6
@export var start_bullets: float = 6 

signal health_changed(new_value: int, max_value: int)
signal bullets_changed(new_value: float, max_value: float)
signal died

#	clampi and clampf forces values to be within the min/max: clampi/f(value, min, max)
var health: int:
	set(value):
		health = clampi(value, 0, max_health)
		health_changed.emit(health, max_health)
		if health == 0:
			died.emit()

var bullets: float:
	set(value):
		bullets = clampf(value, 0, max_bullets)
		bullets_changed.emit(bullets, max_bullets)
		
func _ready() -> void:
	health = start_health
	bullets = start_bullets

func _process(delta: float) -> void:
	pass
		
#	Public funcions that other scripts/nodes will call

func take_damage(amount: int) -> void:
	health -= amount


func spend_bullets(amount: float) -> bool:
	if bullets >= amount:
		bullets -= amount
		return true
	return false

func gain_bullets(amount: float) -> void:
	bullets += amount
