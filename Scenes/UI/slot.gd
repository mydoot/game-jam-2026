class_name Slot extends Panel

## Draggable bullet cell shared by Loadout's revolver grid and available-bullet
## grid. Slots swap BasicBullet resources directly when dropped on one another.
@onready var icon: TextureRect = $TextureRect
@export var bullet: Resource

@onready var select_sfx: AudioStreamPlayer2D = $"../../../../../SelectSFX"

@onready var bullet_load_sfx: AudioStreamPlayer2D = $"../../../../../BulletLoadSFX"

var tween := create_tween()

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
		return
	
	icon.texture = bullet.bullet_textures[0]
	
	#select_sfx.pitch_scale = 2.25
	

## Starts a drag operation using a duplicate Slot as the cursor preview and
## returns this Slot so the drop target can swap their resources.
func _get_drag_data(_at_position: Vector2) -> Variant:
	if not bullet:
		return
		
	var preview = duplicate()
	var control = Control.new()
	control.add_child(preview)
	preview.position -= Vector2(40, 40)
	
	select_sfx.play()
	reset_tween()
	tween.tween_property(preview, "scale", Vector2(1.5, 1.5), 0.1).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	
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
	bullet_load_sfx.play()
	var tmp = bullet
	bullet = data.bullet
	data.bullet = tmp
	icon.show()
	data.icon.show()
	reset_tween()
	tween.tween_property(data, "scale", Vector2(1, 1), 0.1).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	update_ui()
	data.update_ui()
	
	
func reset_tween() -> void:
	if tween:
		tween.kill()
	tween = create_tween()
