extends CanvasLayer

## Player-owned HUD. Player connects Stats signals to the numeric updates and
## asks it to read GlobalVariables whenever Weapon advances the revolver.
@onready var health_label: Label = $VBoxContainer/HealthLabel
@onready var bullet_label: Label = $VBoxContainer/BulletLabel
@onready var bullet_count: Label = $BulletCount
@onready var bullet_icon: TextureRect = $Panel/BulletIcon


## Updates the health readout when Player's Stats emits health_changed.
func update_health(current: int, max_val: int) -> void:
	health_label.text = "Health: %d / %d" % [current, max_val]


## Updates both bullet-count labels when Player's Stats ammo changes.
func update_bullets(current: float, max_val: float) -> void:
	bullet_label.text = "Bullets: %d / %d" % [int(current), int(max_val)]
	bullet_count.text = "%d BULLETS LEFT" % current


## Reads the chambered BasicBullet from GlobalVariables and shows its first
## texture, or clears the icon after Weapon fires the final round.
func update_current_bullet() -> void:
	var current_bullet := GlobalVariables.get_current_bullet() as BasicBullet
	bullet_icon.texture = current_bullet.bullet_textures[0] if current_bullet else null
	bullet_icon.material = current_bullet.create_visual_material() if current_bullet else null
	bullet_icon.modulate = (
		Color.WHITE
		if bullet_icon.material != null or current_bullet == null
		else current_bullet.bullet_color
	)
