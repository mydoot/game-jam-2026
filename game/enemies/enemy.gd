class_name SightEnemy
extends CharacterBody2D

signal defeated(enemy: SightEnemy)
signal alert_changed(enemy: SightEnemy, alert: bool)

@export var vision_range := 260.0
@export_range(1.0, 89.0, 1.0, "degrees") var vision_half_angle_degrees := 32.0
@export var speed := 82.0
@export var contact_damage := 1
@export var attack_cooldown := 0.8
@export var facing := Vector2.LEFT
@export var armored := false

var player: RevolverPlayer
var active := false
var alerted := false
var show_sight := true
var _attack_timer := 0.0
var _player_in_attack_range := false
var _defeated := false

var vision_half_angle: float:
	get: return deg_to_rad(vision_half_angle_degrees)
	set(value): vision_half_angle_degrees = rad_to_deg(value)

func _ready() -> void:
	$AttackRange.body_entered.connect(_on_attack_body_entered)
	$AttackRange.body_exited.connect(_on_attack_body_exited)
	queue_redraw()

func set_player(target: RevolverPlayer) -> void:
	player = target

func activate() -> void:
	active = true
	show_sight = false
	queue_redraw()

func set_planning_sight_visible(value: bool) -> void:
	show_sight = value
	queue_redraw()

func _physics_process(delta: float) -> void:
	_attack_timer = maxf(0.0, _attack_timer - delta)
	if not active or not is_instance_valid(player) or _defeated:
		velocity = Vector2.ZERO
		return
	if not alerted and _can_see_player():
		alerted = true
		alert_changed.emit(self, true)
	if alerted:
		var offset := player.global_position - global_position
		facing = offset.normalized()
		if not _player_in_attack_range:
			velocity = facing * speed
			move_and_slide()
		else:
			velocity = Vector2.ZERO
			if _attack_timer <= 0.0:
				player.take_damage(contact_damage, global_position)
				_attack_timer = attack_cooldown
		queue_redraw()

func _can_see_player() -> bool:
	var offset := player.global_position - global_position
	if offset.length() > vision_range or offset.is_zero_approx():
		return false
	if absf(facing.angle_to(offset.normalized())) > vision_half_angle:
		return false
	var query := PhysicsRayQueryParameters2D.create(global_position, player.global_position, 1 | 2)
	query.exclude = [get_rid()]
	var hit := get_world_2d().direct_space_state.intersect_ray(query)
	return not hit.is_empty() and hit.collider == player

func receive_bullet(definition: BulletDefinition) -> bool:
	if _defeated:
		return false
	if armored and not definition.breaks_armor:
		_flash_blocked()
		return false
	_defeated = true
	collision_layer = 0
	defeated.emit(self)
	queue_free()
	return true

func _flash_blocked() -> void:
	modulate = Color("ffb1c0")
	get_tree().create_timer(0.12).timeout.connect(func():
		if is_instance_valid(self):
			modulate = Color.WHITE
	)

func _on_attack_body_entered(body: Node2D) -> void:
	if body == player:
		_player_in_attack_range = true

func _on_attack_body_exited(body: Node2D) -> void:
	if body == player:
		_player_in_attack_range = false

func _sight_endpoint(angle_offset: float) -> Vector2:
	var ray_direction := facing.rotated(angle_offset)
	var endpoint := global_position + ray_direction * vision_range
	if not is_inside_tree():
		return ray_direction * vision_range
	var query := PhysicsRayQueryParameters2D.create(global_position, endpoint, 1)
	query.exclude = [get_rid()]
	var hit := get_world_2d().direct_space_state.intersect_ray(query)
	return to_local(hit.position) if not hit.is_empty() else ray_direction * vision_range

func _draw() -> void:
	if show_sight:
		var points := PackedVector2Array([Vector2.ZERO])
		for index in range(17):
			points.append(_sight_endpoint(lerpf(-vision_half_angle, vision_half_angle, index / 16.0)))
		draw_colored_polygon(points, Color(1.0, 0.24, 0.2, 0.18))
		draw_polyline(points, Color(1.0, 0.35, 0.25, 0.65), 1.0)
	$Body.color = Color("ff2424") if alerted else Color("d94b55")
	$Armor.visible = armored
	$Facing.position = facing * 9.0

