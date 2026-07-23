class_name MenuBackground
extends Control

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	queue_redraw()

func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), Color("111318"))
	var center := size * Vector2(0.77, 0.52)
	var radius := minf(size.x, size.y) * 0.31
	draw_circle(center, radius, Color("1b1f25"))
	draw_arc(center, radius, 0, TAU, 96, Color("59462d"), 6)
	for index in 6:
		var chamber_center := center + Vector2.RIGHT.rotated(index * TAU / 6.0) * radius * 0.55
		draw_circle(chamber_center, radius * 0.19, Color("0e1014"))
		draw_arc(chamber_center, radius * 0.19, 0, TAU, 32, Color("a67a35"), 3)

