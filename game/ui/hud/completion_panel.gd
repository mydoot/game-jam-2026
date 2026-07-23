class_name CompletionPanel
extends PanelContainer

enum Action { NEXT_LEVEL, REPLAY, LEVEL_SELECT, MAIN_MENU }

signal action_requested(action: Action)

func _ready() -> void:
	%Next.pressed.connect(func(): action_requested.emit(Action.NEXT_LEVEL))
	%Replay.pressed.connect(func(): action_requested.emit(Action.REPLAY))
	%Select.pressed.connect(func(): action_requested.emit(Action.LEVEL_SELECT))
	%Menu.pressed.connect(func(): action_requested.emit(Action.MAIN_MENU))

func present(index: int, reward: BulletDefinition, is_final: bool) -> void:
	%Title.text = "CAMPAIGN COMPLETE" if is_final else "ROOM %02d CLEARED" % (index + 1)
	if reward != null:
		%Reward.text = "NEW AMMUNITION UNLOCKED\n%s" % reward.display_name.to_upper()
	elif is_final:
		%Reward.text = "Every room is clear. Every shot counted."
	else:
		%Reward.text = "ROOM %02d UNLOCKED" % (index + 2)
	%Next.visible = not is_final
	show()
	(%Replay if is_final else %Next).grab_focus()

