class_name BasicBullet extends Resource

## Minimal immutable ammunition definition shared by PlanningUI, Weapon, HUD,
## PlayerProjectile, and shielded sentry damage rules.
enum BulletType { NORMAL, PIERCING, RICOCHET }

@export var display_name := "Normal"
@export_multiline var description := "Stops at the first enemy or wall."
@export var bullet_type: BulletType = BulletType.NORMAL
@export var icon: Texture2D
@export var projectile_tint := Color.WHITE
@export_range(100.0, 1000.0) var speed := 600.0
@export_range(0.1, 10.0) var lifetime := 4.0
@export_range(2.0, 16.0) var collision_radius := 5.0
@export_range(8.0, 48.0) var visual_size := 20.0
@export_range(0, 4) var bounce_count := 0

## Returns the UI/world texture while keeping legacy callers readable.
func get_icon() -> Texture2D:
	return icon
