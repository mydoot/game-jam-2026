class_name BulletFactory extends Node

## Autoload bridge between level roots and Weapon. Each level registers its
## BulletFactory2D here, allowing Weapon to spawn BlastBullets2D shots without a
## fragile scene-tree path.
static var bullet_factory : BulletFactory2D
