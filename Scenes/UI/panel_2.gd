extends Panel

## Keeps the cursor usable during drag/drop and restores hidden slot icons if a
## drag is cancelled outside a valid target.
var data

func _process(_delta: float) -> void:
	if Input.get_current_cursor_shape() == CURSOR_FORBIDDEN:
		DisplayServer.cursor_set_shape(DisplayServer.CURSOR_ARROW)


func _notification(what: int) -> void:
	if what == Node.NOTIFICATION_DRAG_BEGIN:
		data = get_viewport().gui_get_drag_data()
	if what == Node.NOTIFICATION_DRAG_END:
		if not is_drag_successful():
			if data:
				data.icon.show()
				data = null
