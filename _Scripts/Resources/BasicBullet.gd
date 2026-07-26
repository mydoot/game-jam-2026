class_name BasicBullet extends Resource

## Resource schema for a selectable bullet type. Planning/Slot store instances,
## while Weapon uses the values to configure native Godot projectile nodes.
const BULLET_TINT_SHADER := preload("res://Assets/Shaders/bullet_tint.gdshader")

@export_group("Basic Bullet Properties")
@export var bullet_textures : Array[Texture2D]
@export var bullet_max_lifetime: float = 5.0
@export var bullet_texture_size: Vector2 = Vector2(22.4, 22.4)
@export var bullet_collision_shape_size: Vector2 = Vector2(11.2, 11.2)
@export var bullet_collision_shape_offset: Vector2 = Vector2.ZERO
@export var bullet_change_texture_time: float = 0.1
@export var bullet_color: Color = Color.WHITE
@export var recolor_texture: bool = false

@export_group("Bullet Speed Properties")
@export_range(1, 32, 1) var amount_of_bullets: int = 1
@export var min_speed: float = 600.0
@export var max_speed: float = 600.0
@export var minimum_max_speed: float = 600.0
@export var maximum_max_speed: float = 600.0
@export var max_accel: float = 500.0
@export var min_accel: float = 500.0


## Specialized resources override these methods without coupling Weapon or the
## projectile scene to a plugin-specific data type.
func pierces_enemies() -> bool:
	return false


func wall_bounce_count() -> int:
	return 0


## Creates an independent material for bullet types that recolor an existing
## texture rather than supplying a separate art asset.
func create_visual_material() -> ShaderMaterial:
	if not recolor_texture:
		return null

	var tint_material := ShaderMaterial.new()
	tint_material.shader = BULLET_TINT_SHADER
	tint_material.set_shader_parameter("tint_color", bullet_color)
	return tint_material
