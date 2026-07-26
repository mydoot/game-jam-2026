class_name SentryPlacement extends Resource

## Typed enemy-placement data consumed by GameState and CampaignLevel.
@export var tile := Vector2i.ZERO
@export var facing_radians := 0.0
@export var sight_range := 300.0
@export var fire_delay := 1.5
@export var requires_ricochet := false

## Initializes a placement while keeping catalog declarations compact.
func setup(position: Vector2i, facing_degrees: float, sight: float, delay: float, shielded := false) -> SentryPlacement:
	tile = position
	facing_radians = deg_to_rad(facing_degrees)
	sight_range = maxf(sight, 1.0)
	fire_delay = maxf(delay, 0.1)
	requires_ricochet = shielded
	return self
