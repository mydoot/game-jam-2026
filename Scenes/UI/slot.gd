extends Panel

@onready var icon: TextureRect = $TextureRect

func _get_drag_data(at_position: Vector2) -> Variant:
	if icon.texture == null:
		return
		
	var preview = duplicate()
	var control = Control.new()
	control.add_child(preview)
	preview.position -= Vector2(40, 40)
	#preview.self_modulate = Color.TRANSPARENT
	
	
	set_drag_preview(control)
	icon.hide()
	return icon

func _can_drop_data(_at_position: Vector2, _data: Variant) -> bool:
	return true
	
func _drop_data(_at_position: Vector2, data: Variant) -> void:
	var tmp = icon.texture
	icon.texture = data.texture
	data.texture = tmp
	icon.show()
	data.show()
