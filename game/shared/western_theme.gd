class_name WesternTheme
extends RefCounted

const BRASS := Color("d9a441")
const BRASS_BRIGHT := Color("ffd271")
const GUNMETAL := Color("20242a")
const PANEL := Color("2c3037")
const INK := Color("111318")
const DANGER := Color("b94645")
const TEXT := Color("f0e5ce")
const MUTED := Color("99958c")

static func make() -> Theme:
	var result := Theme.new()
	result.default_font_size = 18
	result.set_color("font_color", "Label", TEXT)
	result.set_color("font_color", "Button", TEXT)
	result.set_color("font_hover_color", "Button", INK)
	result.set_color("font_focus_color", "Button", INK)
	result.set_color("font_disabled_color", "Button", MUTED.darkened(0.35))
	result.set_stylebox("normal", "Button", _box(PANEL, BRASS.darkened(0.45), 2))
	result.set_stylebox("hover", "Button", _box(BRASS, BRASS_BRIGHT, 2))
	result.set_stylebox("pressed", "Button", _box(BRASS.darkened(0.18), BRASS_BRIGHT, 3))
	result.set_stylebox("focus", "Button", _box(BRASS, Color.WHITE, 4))
	result.set_stylebox("disabled", "Button", _box(GUNMETAL.darkened(0.15), MUTED.darkened(0.45), 1))
	result.set_stylebox("panel", "PanelContainer", _box(Color(PANEL, 0.96), BRASS.darkened(0.3), 2, 16))
	return result

static func _box(fill: Color, border: Color, width: int, padding := 10) -> StyleBoxFlat:
	var box := StyleBoxFlat.new()
	box.bg_color = fill
	box.border_color = border
	box.set_border_width_all(width)
	box.set_corner_radius_all(5)
	box.content_margin_left = padding
	box.content_margin_right = padding
	box.content_margin_top = padding
	box.content_margin_bottom = padding
	return box

