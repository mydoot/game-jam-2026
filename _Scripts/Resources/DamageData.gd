class_name DamageData extends Resource

## Metadata carried by spawned bullets so hit routing can determine damage,
## ownership, and bullet-type behaviors.
var damage: int

var is_from_player: bool

@export_group("Bullet Type Booleans")
var is_ricoshot: bool

var is_piercing: bool
