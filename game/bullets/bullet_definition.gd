class_name BulletDefinition
extends Resource

## Editable contract for a single tactical projectile type.

enum Kind { NORMAL, RICOCHET, PIERCING, TERRAIN, ARMOR_BREAKING }

@export var kind: Kind = Kind.NORMAL
@export var display_name := "Normal"
@export var color := Color.WHITE
@export var speed := 620.0
@export var lifetime := 2.5
@export var damage := 1
@export var max_bounces := 0
@export var pierces_enemies := false
@export var alters_terrain := false
@export var breaks_armor := false

