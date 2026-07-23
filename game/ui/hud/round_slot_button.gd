class_name RoundSlotButton
extends Button

signal round_dropped(from_container: String, from_index: int, to_container: String, to_index: int)

var container_name := ""
var slot_index := -1
var has_round := false

func _get_drag_data(_position: Vector2) -> Variant:
	if not has_round:
		return null
	var preview := Label.new()
	preview.text = text
	preview.modulate = modulate
	set_drag_preview(preview)
	return {"round_container": container_name, "round_index": slot_index}

func _can_drop_data(_position: Vector2, data: Variant) -> bool:
	return data is Dictionary and data.has("round_container") and data.has("round_index")

func _drop_data(_position: Vector2, data: Variant) -> void:
	round_dropped.emit(str(data.round_container), int(data.round_index), container_name, slot_index)

