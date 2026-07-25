class_name Stats
extends Node

## Player-owned health and ammo component. Player connects its change signals to
## HUD and its died signal to the GameOver flow.
@export_group("Health (Hearts)")
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
		

## Applies exported starting values through the setters so listeners receive a
## consistent initial state.
func _ready() -> void:
	health = start_health
	bullets = start_bullets


## Reduces health through the clamped setter, which emits health_changed/died.
func take_damage(amount: int) -> void:
	health -= amount


## Lets Player atomically check and spend ammo before asking Weapon to fire.
func spend_bullets(amount: float) -> bool:
	if bullets >= amount:
		bullets -= amount
		return true
	return false


## Adds ammo while respecting max_bullets through the setter clamp.
func gain_bullets(amount: float) -> void:
	bullets += amount
