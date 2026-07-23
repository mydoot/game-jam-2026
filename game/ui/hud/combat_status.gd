class_name CombatStatus
extends PanelContainer

func setup(level: LevelDefinition, health: int, maximum: int, enemies: int) -> void:
	%Room.text = level.title
	update_health(health, maximum)
	update_enemy_count(enemies)
	update_cylinder([])
	%Status.text = "PLANNING"

func show_combat() -> void:
	%Status.text = "ELIMINATE ALL ENEMIES"

func show_clear() -> void:
	%Status.text = "ROOM CLEAR — EXIT UNLOCKED"

func update_health(current: int, maximum: int) -> void:
	%Health.text = "HEALTH  %d / %d" % [current, maximum]

func update_enemy_count(remaining: int) -> void:
	%Enemies.text = "ENEMIES  %d" % remaining

func update_cylinder(rounds: Array[BulletDefinition]) -> void:
	for child in %Cylinder.get_children():
		child.queue_free()
	if rounds.is_empty():
		var empty := Label.new()
		empty.text = "EMPTY"
		%Cylinder.add_child(empty)
		return
	for index in rounds.size():
		var label := Label.new()
		label.text = "●"
		label.tooltip_text = rounds[index].display_name
		label.modulate = rounds[index].color
		label.add_theme_font_size_override("font_size", 24 if index == 0 else 18)
		%Cylinder.add_child(label)

