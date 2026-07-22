extends CanvasLayer

@onready var health_label: Label = $VBoxContainer/HealthLabel
@onready var bullet_label: Label = $VBoxContainer/BulletLabel

func update_health(current: int, max_val: int) -> void:
	health_label.text = "Health: %d / %d" % [current, max_val]

func update_bullets(current: float, max_val: float) -> void:
	bullet_label.text = "Bullets: %d / %d" % [int(current), int(max_val)]
