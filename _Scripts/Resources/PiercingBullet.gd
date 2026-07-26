class_name PiercingBullet extends BasicBullet

## Specialized BasicBullet resource used by Slot, Weapon, and HUD. It reuses the
## standard native projectile setup while allowing it to pass through enemies.

func pierces_enemies() -> bool:
	return true
