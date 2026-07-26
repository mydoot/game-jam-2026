extends CanvasLayer

## Player-owned HUD. Player connects Stats signals to the numeric updates and
## asks it to read GlobalVariables whenever Weapon advances the revolver.
@onready var health_label: Label = $VBoxContainer/HealthLabel
@onready var bullet_label: Label = $VBoxContainer/BulletLabel
@onready var bullet_count: Label = $BulletCount
@onready var bullet_icon: TextureRect = $Panel/BulletIcon

var tween := create_tween()

func _ready() -> void:
	bullet_count.pivot_offset = bullet_count.size / 2

## Updates the health readout when Player's Stats emits health_changed.
func update_health(current: int, max_val: int) -> void:
	health_label.text = "Health: %d / %d" % [current, max_val]


## Updates both bullet-count labels when Player's Stats ammo changes.
func update_bullets(current: float, max_val: float) -> void:
	bullet_label.text = "Bullets: %d / %d" % [int(current), int(max_val)]
	bullet_count.text = "%d BULLETS LEFT" % current
	
	var bullets_used : float = current / max_val
	_update_bullet_animation(bullets_used)

## Reads the chambered BasicBullet from GlobalVariables and shows its first
## texture, or clears the icon after Weapon fires the final round.
func update_current_bullet() -> void:
	var current_bullet = GlobalVariables.get_current_bullet()
	bullet_icon.texture = current_bullet.bullet_textures[0] if current_bullet else null

func reset_tween() -> void:
	if tween:
		tween.kill()
	tween = create_tween()

func _update_bullet_animation(count_percent: float) -> void:
	reset_tween()
	tween.set_parallel(true)
	tween.tween_property(bullet_count, "scale", Vector2(2, 2).lerp(Vector2(1, 1), count_percent), 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	tween.tween_property(bullet_count, "modulate", Color.RED.lerp(Color.WHITE, count_percent), 0.1).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
