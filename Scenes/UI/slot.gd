class_name Slot extends Panel

## Draggable bullet cell shared by Loadout's revolver grid and available-bullet
## grid. Slots swap BasicBullet resources directly when dropped on one another.
@onready var icon: TextureRect = $TextureRect
@export var bullet: Resource

## Initializes the icon from the bullet resource assigned by the scene or Loadout.
func _ready() -> void:
	update_ui()


## Mirrors the assigned BasicBullet resource into the visible slot icon.
func update_ui() -> void:
	if icon == null:
		icon = get_node_or_null("TextureRect")
	if icon == null:
		push_warning("Bullet slot is missing its TextureRect.")
		return
	if not bullet:
		icon.texture = null
		icon.modulate = Color.WHITE
		icon.material = null
		return

	var bullet_resource := bullet as BasicBullet
	if bullet_resource == null:
		icon.texture = null
		icon.modulate = Color.WHITE
		icon.material = null
		return

	icon.texture = bullet_resource.bullet_textures[0]
	icon.material = bullet_resource.create_visual_material()
	icon.modulate = Color.WHITE if icon.material != null else bullet_resource.bullet_color
	

## Starts a drag operation using a duplicate Slot as the cursor preview and
## returns this Slot so the drop target can swap their resources.
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


## Accepts only another Slot, preventing unrelated UI drag data from reaching the
## swap callback.
func _can_drop_data(_at_position: Vector2, _data: Variant) -> bool:
	return _data is Slot
	

## Swaps bullet resources between two Slots and refreshes both icons.
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
