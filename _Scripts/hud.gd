extends CanvasLayer

## Combat HUD mirrors the ordered cylinder, current round, ammunition count,
## local sentry count, and exit lock state from Player/CampaignLevel.
@onready var health_label: Label = $VBoxContainer/HealthLabel
@onready var bullet_label: Label = $VBoxContainer/BulletLabel
@onready var bullet_count: Label = $BulletCount
@onready var bullet_icon: TextureRect = $Panel/BulletIcon
@onready var chamber_row: HBoxContainer = $Chambers
@onready var objective_label: Label = $Objective

## Connects local level signals after Player and HUD enter the active room.
func _ready() -> void:
	var level := get_tree().get_first_node_in_group("level") as CampaignLevel
	if level:
		level.enemy_count_changed.connect(_on_enemy_count_changed)
		level.phase_changed.connect(_on_phase_changed)
		_on_enemy_count_changed(level.enemies_alive)
		_on_phase_changed(level.phase)

## Updates the hidden compatibility health readout.
func update_health(current: int, max_val: int) -> void:
	health_label.text = "Health: %d / %d" % [current, max_val]

## Updates ammunition labels using integer chamber counts.
func update_bullets(current: int, max_val: int) -> void:
	bullet_label.text = "Bullets: %d / %d" % [current, max_val]
	bullet_count.text = "%d ROUND%s" % [current, "" if current == 1 else "S"]

## Refreshes current-round art and the remaining left-to-right cylinder.
func update_current_bullet() -> void:
	var current := GlobalVariables.get_current_bullet() as BasicBullet
	bullet_icon.texture = current.get_icon() if current else null
	for child in chamber_row.get_children():
		chamber_row.remove_child(child)
		child.queue_free()
	for bullet_resource in GlobalVariables.bullet_loadout:
		var bullet := bullet_resource as BasicBullet
		var icon := TextureRect.new()
		icon.custom_minimum_size = Vector2(34, 42)
		icon.texture = bullet.get_icon()
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon.tooltip_text = bullet.display_name
		chamber_row.add_child(icon)

## Displays the local enemy count without querying global groups.
func _on_enemy_count_changed(remaining: int) -> void:
	objective_label.text = "SENTRIES  %d" % remaining

## Replaces the objective with exit guidance when the room clears.
func _on_phase_changed(phase: CampaignLevel.LevelPhase) -> void:
	if phase == CampaignLevel.LevelPhase.CLEARED:
		objective_label.text = "EXIT OPEN"
