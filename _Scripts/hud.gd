extends CanvasLayer

## Displays player health, remaining bullets, and the next bullet currently in
## the revolver queue.
@onready var health_label: Label = $VBoxContainer/HealthLabel
@onready var bullet_label: Label = $VBoxContainer/BulletLabel
@onready var bullet_count: Label = $BulletCount
@onready var bullet_icon: TextureRect = $Panel/BulletIcon


## Updates the health readout when the Stats node emits health_changed.
func update_health(current: int, max_val: int) -> void:
	health_label.text = "Health: %d / %d" % [current, max_val]


## Updates both bullet-count labels when ammo changes.
func update_bullets(current: float, max_val: float) -> void:
	bullet_label.text = "Bullets: %d / %d" % [int(current), int(max_val)]
	bullet_count.text = "%d BULLETS LEFT" % current


## Shows the next bullet's icon, or clears it after the last bullet is fired.
func update_current_bullet() -> void:
	var current_bullet = GlobalVariables.get_current_bullet()
	bullet_icon.texture = current_bullet.bullet_textures[0] if current_bullet else null
