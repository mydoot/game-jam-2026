class_name SceneNavigator
extends Node

var transitioning := false

func navigate(scene_path: String) -> void:
	if transitioning:
		return
	transitioning = true
	get_tree().paused = false
	var overlay := CanvasLayer.new()
	overlay.layer = 1000
	overlay.process_mode = Node.PROCESS_MODE_ALWAYS
	var fade := ColorRect.new()
	fade.color = Color(0.03, 0.025, 0.025, 0.0)
	fade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	fade.mouse_filter = Control.MOUSE_FILTER_STOP
	overlay.add_child(fade)
	get_tree().root.add_child(overlay)
	var conceal := create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	conceal.tween_property(fade, "color:a", 1.0, 0.16)
	await conceal.finished
	get_tree().change_scene_to_file(scene_path)
	await get_tree().process_frame
	var reveal := create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	reveal.tween_property(fade, "color:a", 0.0, 0.16)
	await reveal.finished
	overlay.queue_free()
	transitioning = false

