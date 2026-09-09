class_name ArenaHud
extends CanvasLayer

signal character_selected(index: int)
signal weapon_selected(index: int)
signal menu_requested

var root: Control
var menu: VBoxContainer
var overlay: Control
var health_label: Label
var ammo_label: Label
var ability_label: Label
var objective_label: Label
var message_label: Label
var message_time: float = 0.0

func setup() -> void:
	root = Control.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(root)
	overlay = Control.new()
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(overlay)
	health_label = make_label("", Vector2(28, 28), Vector2(280, 50), 22)
	ammo_label = make_label("", Vector2(980, 28), Vector2(270, 58), 28)
	ability_label = make_label("", Vector2(28, 626), Vector2(500, 64), 18)
	objective_label = make_label("", Vector2(460, 24), Vector2(360, 42), 18)
	objective_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	message_label = make_label("", Vector2(340, 94), Vector2(600, 34), 18)
	message_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var crosshair := make_label("+", Vector2(630, 333), Vector2(20, 36), 30)
	crosshair.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	set_hud_visible(false)

func make_label(value: String, at: Vector2, dimensions: Vector2, font_size: int) -> Label:
	var label := Label.new()
	label.text = value
	label.position = at
	label.size = dimensions
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", Color("e9f9ff"))
	label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.85))
	label.add_theme_constant_override("shadow_offset_x", 2)
	label.add_theme_constant_override("shadow_offset_y", 2)
	overlay.add_child(label)
	return label

func show_character_selection(characters: Array[Dictionary]) -> void:
	set_hud_visible(false)
	build_menu("NEON STRIKE", "SELECT YOUR 3D ARENA OPERATIVE")
	for index in range(characters.size()):
		var hero: Dictionary = characters[index]
		var button := add_option(hero["name"], hero["ability"] + "  |  " + hero["description"], hero["color"])
		button.pressed.connect(emit_character_selected.bind(index))

func show_weapon_selection(hero: Dictionary, weapons: Array[Dictionary]) -> void:
	build_menu("ARMORY", str(hero["name"]) + " SELECT YOUR PRIMARY WEAPON")
	for index in range(weapons.size()):
		var weapon: Dictionary = weapons[index]
		var detail := str(weapon["tag"]) + "  |  DMG " + str(int(weapon["damage"])) + "  |  MAG " + str(weapon["magazine"])
		var button := add_option(weapon["name"], detail, weapon["color"])
		button.pressed.connect(emit_weapon_selected.bind(index))

func show_end_screen(won: bool, kills: int, elapsed: float) -> void:
	set_hud_visible(false)
	var title := "DISTRICT SECURED" if won else "OPERATIVE DOWN"
	var detail := "HOSTILES ELIMINATED: %02d   TIME: %02d:%02d" % [kills, int(elapsed) / 60, int(elapsed) % 60]
	build_menu(title, detail)
	var button := add_option("RETURN TO OPERATIVE SELECT", "Choose another specialist or weapon loadout", Color("8eeeff"))
	button.pressed.connect(emit_menu_requested)

func emit_character_selected(index: int) -> void:
	character_selected.emit(index)

func emit_weapon_selected(index: int) -> void:
	weapon_selected.emit(index)

func emit_menu_requested() -> void:
	menu_requested.emit()

func build_menu(title: String, subtitle: String) -> void:
	if menu != null:
		menu.queue_free()
	menu = VBoxContainer.new()
	menu.set_anchors_preset(Control.PRESET_CENTER)
	menu.position = Vector2(-265, -245)
	menu.size = Vector2(530, 490)
	menu.add_theme_constant_override("separation", 12)
	root.add_child(menu)
	var title_label := Label.new()
	title_label.text = title
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.add_theme_font_size_override("font_size", 34)
	title_label.add_theme_color_override("font_color", Color("ecfbff"))
	menu.add_child(title_label)
	var subtitle_label := Label.new()
	subtitle_label.text = subtitle
	subtitle_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	subtitle_label.add_theme_font_size_override("font_size", 15)
	subtitle_label.add_theme_color_override("font_color", Color("9fc3ce"))
	menu.add_child(subtitle_label)

func add_option(title: String, detail: String, color: Color) -> Button:
	var button := Button.new()
	button.text = title + "\n" + detail
	button.custom_minimum_size = Vector2(530, 82)
	button.add_theme_font_size_override("font_size", 17)
	button.add_theme_color_override("font_color", color)
	menu.add_child(button)
	return button

func set_hud_visible(value: bool) -> void:
	overlay.visible = value

func show_game_hud() -> void:
	if menu != null:
		menu.queue_free()
		menu = null
	set_hud_visible(true)

func update_hud(health: float, weapon: Dictionary, ammo: int, reserve: int, ability: Dictionary, ability_time: float, cooldown: float, kills: int, target_kills: int) -> void:
	health_label.text = "HEALTH  %03d" % int(maxf(0.0, health))
	ammo_label.text = str(weapon["name"]).to_upper() + "\n%02d / %03d" % [ammo, reserve]
	var status := "READY" if cooldown == 0.0 else "%.1fs" % cooldown
	if ability_time > 0.0:
		status = "ACTIVE  %.1fs" % ability_time
	ability_label.text = "[Q] " + str(ability["ability"]) + "   " + status
	ability_label.add_theme_color_override("font_color", ability["color"])
	objective_label.text = "HOSTILES  %02d / %02d" % [kills, target_kills]

func show_message(value: String, duration: float) -> void:
	message_label.text = value
	message_time = duration

func _process(delta: float) -> void:
	if message_time > 0.0:
		message_time = maxf(0.0, message_time - delta)
		if message_time == 0.0:
			message_label.text = ""
