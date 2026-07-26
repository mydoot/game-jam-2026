class_name RicochetBullet extends BasicBullet

## A normal player bullet that can reflect from exactly one terrain surface.

func wall_bounce_count() -> int:
	return 1
