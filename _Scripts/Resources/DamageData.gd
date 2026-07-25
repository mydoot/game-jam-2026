class_name DamageData extends Resource

## Per-shot metadata created by Weapon and carried by BlastBullets2D. The level
## controller reads it to route damage and later bullet-type behavior.
var damage: int

var is_from_player: bool

@export_group("Bullet Type Booleans")
var is_ricoshot: bool

var is_piercing: bool
