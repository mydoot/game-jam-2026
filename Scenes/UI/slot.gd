class_name Slot extends Panel

## One draggable bullet slot used by both the selected loadout and the available
## bullet pool on the planning screen.
@onready var icon: TextureRect = $TextureRect
@export var bullet: Resource

func _ready() -> void:
	update_ui()


## Mirrors the assigned bullet resource into the visible slot icon.
func update_ui() -> void:
	if icon == null:
		icon = get_node_or_null("TextureRect")
	if icon == null:
		push_warning("Bullet slot is missing its TextureRect.")
		return
	if not bullet:
		icon.texture = null
		return
		
	icon.texture = bullet.bullet_textures[0]
	

## Starts a drag operation by using a duplicate slot as the preview.
func _get_drag_data(_at_position: Vector2) -> Variant:
	if not bullet:
		return
		
	var preview = duplicate()
	var control = Control.new()
	control.add_child(preview)
	preview.position -= Vector2(40, 40)
	
	set_drag_preview(control)
	icon.hide()
	return self


func _can_drop_data(_at_position: Vector2, _data: Variant) -> bool:
	return _data is Slot
	

## Swaps bullet resources between two slots and refreshes both icons.
func _drop_data(_at_position: Vector2, data: Variant) -> void:
	if not (data is Slot):
		return
	var tmp = bullet
	bullet = data.bullet
	data.bullet = tmp
	icon.show()
	data.icon.show()
	update_ui()
	data.update_ui()
