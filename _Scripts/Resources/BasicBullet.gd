class_name BasicBullet extends Resource

var bullet_data : DirectionalBulletsData2D

@export_group("Basic Bullet Properties")
@export var bullet_textures : Array[Texture2D]
@export var bullet_max_lifetime : float
@export var bullet_texture_size : Vector2
@export var bullet_collision_shape_size : Vector2
@export var bullet_collision_shape_offset : Vector2
@export var bullet_change_texture_time : float

@export_group("Bullet Speed Properties")
## This value should be the equal to the amount of bullets to be spawned.
@export var amount_of_bullets : int
@export var min_speed : float
@export var max_speed : float
@export var minimum_max_speed : float
@export var maximum_max_speed : float
@export var max_accel : float
@export var min_accel : float


# Returns a partially set up DirectionalBulletsData2D, only thing left to do is set a new value to the .transforms property when the fire cooldown timer times out and you are ready to spawn a new batch of bullets..
func set_up_bullet_data() -> DirectionalBulletsData2D:
	var data : DirectionalBulletsData2D = DirectionalBulletsData2D.new()
	data.textures = bullet_textures
	
	data.all_bullet_speed_data = BulletSpeedData2D.generate_random_data(amount_of_bullets, min_speed, max_speed, maximum_max_speed, minimum_max_speed, min_accel, max_accel)
	
	data.set_collision_layer_from_array([2])
	data.set_collision_mask_from_array([1, 3])

	data.texture_size = bullet_texture_size
	data.collision_shape_size = bullet_collision_shape_size
	data.collision_shape_offset = bullet_collision_shape_offset
	data.default_change_texture_time = bullet_change_texture_time
	data.max_life_time = bullet_max_lifetime
	#data.all_bullet_rotation_data = bullet_rotation_data
	#data.bullets_custom_data = damage_data
	
	
	return data
