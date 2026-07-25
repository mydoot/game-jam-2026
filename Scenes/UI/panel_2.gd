extends Panel

## Supports Slot drag/drop for the available-bullets panel. It normalizes the
## cursor and restores the source Slot icon when Godot cancels a drag.
var data

## Replaces Godot's forbidden cursor with the normal arrow during slot dragging.
func _process(_delta: float) -> void:
	if Input.get_current_cursor_shape() == CURSOR_FORBIDDEN:
		DisplayServer.cursor_set_shape(DisplayServer.CURSOR_ARROW)


## Captures the dragged Slot at drag start and restores its icon after a failed
## drop. Slot itself handles successful swaps.
func _notification(what: int) -> void:
	if what == Node.NOTIFICATION_DRAG_BEGIN:
		data = get_viewport().gui_get_drag_data()
	if what == Node.NOTIFICATION_DRAG_END:
		if not is_drag_successful():
			if data:
				data.icon.show()
				data = null
