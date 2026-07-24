extends Panel

@onready var icon: TextureRect = $TextureRect
@export var bullet: Resource

func _ready() -> void:
	update_ui()


func update_ui() -> void:
	if not bullet:
		icon.texture = null
		return
		
	icon.texture = bullet.bullet_textures[0]
	icon.tooltip_text = "basic bullet"
	
func _get_drag_data(at_position: Vector2) -> Variant:
	if not bullet:
		return
		
	var preview = duplicate()
	var control = Control.new()
	control.add_child(preview)
	preview.position -= Vector2(40, 40)
	#preview.self_modulate = Color.TRANSPARENT
	
	
	set_drag_preview(control)
	icon.hide()
	return self

func _can_drop_data(_at_position: Vector2, _data: Variant) -> bool:
	return true
	
func _drop_data(_at_position: Vector2, data: Variant) -> void:
	var tmp = bullet
	bullet = data.bullet
	data.bullet = tmp
	icon.show()
	data.icon.show()
	update_ui()
	data.update_ui()
