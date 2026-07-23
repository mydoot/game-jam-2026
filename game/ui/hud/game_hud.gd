class_name GameHUD
extends CanvasLayer

signal start_requested(rounds: Array[BulletDefinition])
signal restart_requested
signal completion_action_requested(action: CompletionPanel.Action)

@onready var planning: PlanningPanel = %Planning
@onready var combat: CombatStatus = %Combat
@onready var failure: FailurePanel = %Failure
@onready var completion: CompletionPanel = %Completion

func _ready() -> void:
	var ui_theme := WesternTheme.make()
	planning.theme = ui_theme
	combat.theme = ui_theme
	failure.theme = ui_theme
	completion.theme = ui_theme
	planning.start_requested.connect(func(rounds: Array[BulletDefinition]): start_requested.emit(rounds))
	failure.restart_requested.connect(func(): restart_requested.emit())
	completion.action_requested.connect(func(action: CompletionPanel.Action): completion_action_requested.emit(action))

func setup(level: LevelDefinition, health: int, maximum: int, enemies: int) -> void:
	planning.setup(level)
	combat.setup(level, health, maximum, enemies)
	failure.hide()
	completion.hide()

func show_combat() -> void:
	planning.hide()
	combat.show_combat()

func show_clear() -> void:
	combat.show_clear()

func show_failure(reason: String) -> void:
	failure.present(reason)

func show_level_complete(index: int, reward: BulletDefinition, is_final: bool) -> void:
	failure.hide()
	completion.present(index, reward, is_final)

func update_health(current: int, maximum: int) -> void:
	combat.update_health(current, maximum)

func update_enemy_count(remaining: int) -> void:
	combat.update_enemy_count(remaining)

func update_cylinder(rounds: Array[BulletDefinition]) -> void:
	combat.update_cylinder(rounds)
