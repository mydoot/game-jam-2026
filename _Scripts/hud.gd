extends CanvasLayer

@onready var health_label: Label = $VBoxContainer/HealthLabel
@onready var bullet_label: Label = $VBoxContainer/BulletLabel
@onready var bullet_count: Label = $BulletCount
@onready var bullet_icon: TextureRect = $Panel/BulletIcon

func _ready() -> void:
	pass

func update_health(current: int, max_val: int) -> void:
	health_label.text = "Health: %d / %d" % [current, max_val]

func update_bullets(current: float, max_val: float) -> void:
	bullet_label.text = "Bullets: %d / %d" % [int(current), int(max_val)]
	bullet_count.text = "%d BULLETS LEFT" % current

func update_current_bullet() -> void:
	bullet_icon.texture = GlobalVariables.current_bullet.bullet_textures[0]
