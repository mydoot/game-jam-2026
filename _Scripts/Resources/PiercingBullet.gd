class_name PiercingBullet extends BasicBullet

## Specialized BasicBullet resource used by Slot, Weapon, and HUD. It reuses the
## standard visual, movement, and collision-layer setup while allowing the plugin
## projectile to survive enemy collisions.

@export_group("Piercing Bullet Properties")
## BlastBullets2D uses zero for an unlimited collision count.
@export var bullet_collision_count: int = 0


## Extends BasicBullet's known-good setup with the collision count that allows
## this projectile to continue after hitting one or more enemies.
func set_up_bullet_data() -> DirectionalBulletsData2D:
	var data := super.set_up_bullet_data()
	data.bullet_max_collision_count = bullet_collision_count
	return data
