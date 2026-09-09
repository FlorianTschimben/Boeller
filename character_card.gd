extends Button

var character: Dictionary
var is_selected: bool = false

func configure(data: Dictionary) -> void:
	character = data
	custom_minimum_size = Vector2(350, 350)
	tooltip_text = "Select " + str(character["name"])
	queue_redraw()

func set_selected(value: bool) -> void:
	is_selected = value
	queue_redraw()

func _draw() -> void:
	if character.is_empty():
		return
	var primary: Color = character["color"]
	var accent: Color = character["accent"]
	var border: Color = accent if is_selected else primary.darkened(0.25)
	var background := Color(primary, 0.16 if is_selected else 0.07)
	draw_rect(Rect2(Vector2.ZERO, size), background, true)
	draw_rect(Rect2(Vector2.ZERO, size), border, false, 3.0 if is_selected else 1.0)
	var center := Vector2(size.x * 0.5, 128)
	draw_circle(center, 62, primary.darkened(0.55))
	draw_circle(center, 50, Color("10202a"))
	draw_character_silhouette(center, primary, accent)
	var title_font := ThemeDB.fallback_font
	draw_string(title_font, center + Vector2(-7, 7), str(character["symbol"]), HORIZONTAL_ALIGNMENT_LEFT, -1, 18, accent)
	draw_string(title_font, Vector2(22, 222), str(character["name"]), HORIZONTAL_ALIGNMENT_LEFT, -1, 24, accent)
	draw_string(title_font, Vector2(22, 248), str(character["role"]), HORIZONTAL_ALIGNMENT_LEFT, -1, 13, primary)
	draw_string(title_font, Vector2(22, 286), "ABILITY  " + str(character["ability"]), HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color("e8f8fb"))
	draw_string(title_font, Vector2(22, 315), "SPECIAL  " + str(character["special_weapon"]["name"]), HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color("b7ccd4"))
	if is_selected:
		draw_string(title_font, Vector2(22, 340), "SELECTED", HORIZONTAL_ALIGNMENT_LEFT, -1, 12, accent)

func draw_character_silhouette(center: Vector2, primary: Color, accent: Color) -> void:
	var style: String = character["portrait_style"]
	if style == "armored":
		draw_rect(Rect2(center + Vector2(-30, 4), Vector2(60, 54)), primary, true)
		draw_rect(Rect2(center + Vector2(-40, 18), Vector2(14, 33)), accent, true)
		draw_rect(Rect2(center + Vector2(26, 18), Vector2(14, 33)), accent, true)
		draw_circle(center + Vector2(0, -18), 22, accent)
	elif style == "runner":
		draw_circle(center + Vector2(0, -20), 20, accent)
		draw_colored_polygon(PackedVector2Array([center + Vector2(-22, 5), center + Vector2(28, 20), center + Vector2(8, 60), center + Vector2(-34, 48)]), primary)
		draw_line(center + Vector2(-18, 20), center + Vector2(30, 39), accent, 5.0)
		draw_line(center + Vector2(-8, 45), center + Vector2(30, 64), accent, 4.0)
	else:
		draw_colored_polygon(PackedVector2Array([center + Vector2(0, -55), center + Vector2(42, 10), center + Vector2(25, 58), center + Vector2(-25, 58), center + Vector2(-42, 10)]), primary)
		draw_circle(center + Vector2(0, -10), 22, Color("16222d"))
		draw_circle(center + Vector2(0, -10), 8, accent)
		draw_line(center + Vector2(-22, 48), center + Vector2(28, 48), accent, 3.0)
