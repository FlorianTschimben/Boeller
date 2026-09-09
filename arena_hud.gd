class_name ArenaHud
extends CanvasLayer

const CharacterCard = preload("res://character_card.gd")

signal character_selected(index: int)
signal weapon_selected(index: int)
signal menu_requested
signal resume_requested
signal restart_requested
signal loadout_requested
signal settings_requested
signal settings_back_requested
signal mouse_sensitivity_changed(value: float)
signal field_of_view_changed(value: float)
signal master_volume_changed(value: float)
signal fullscreen_changed(value: bool)

var root: Control
var menu: VBoxContainer
var overlay: Control
var health_label: Label
var ammo_label: Label
var ability_label: Label
var objective_label: Label
var message_label: Label
var message_time: float = 0.0
var menu_mode: String = ""
var character_screen: Control
var selection_cards: Array = []
var roster: Array[Dictionary] = []
var highlighted_character: int = 0
var selection_detail: Label
var confirm_character: Button

func setup() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
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

func show_character_selection(characters: Array[Dictionary], selected_index: int = 0) -> void:
	menu_mode = "character_select"
	set_hud_visible(false)
	clear_menu()
	clear_character_screen()
	roster = characters
	highlighted_character = clampi(selected_index, 0, characters.size() - 1)
	character_screen = Control.new()
	character_screen.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.add_child(character_screen)
	var title := make_screen_label("NEON STRIKE", Vector2(64, 46), Vector2(1150, 52), 36, Color("ecfbff"))
	character_screen.add_child(title)
	var subtitle := make_screen_label("OPERATIVE ROSTER  /  SELECT A SPECIALIST", Vector2(68, 94), Vector2(1100, 28), 15, Color("8fc5d4"))
	character_screen.add_child(subtitle)
	var scroll := ScrollContainer.new()
	scroll.position = Vector2(58, 136)
	scroll.size = Vector2(1164, 372)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	character_screen.add_child(scroll)
	var card_row := HBoxContainer.new()
	card_row.add_theme_constant_override("separation", 18)
	scroll.add_child(card_row)
	for index in range(characters.size()):
		var card: Variant = CharacterCard.new()
		card.configure(characters[index])
		card.pressed.connect(highlight_character.bind(index))
		card_row.add_child(card)
		selection_cards.append(card)
	selection_detail = make_screen_label("", Vector2(76, 538), Vector2(730, 122), 16, Color("d6eaf0"))
	selection_detail.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	character_screen.add_child(selection_detail)
	confirm_character = Button.new()
	confirm_character.position = Vector2(840, 548)
	confirm_character.size = Vector2(350, 92)
	confirm_character.add_theme_font_size_override("font_size", 18)
	confirm_character.pressed.connect(confirm_highlighted_character)
	character_screen.add_child(confirm_character)
	highlight_character(highlighted_character)

func show_weapon_selection(hero: Dictionary, weapons: Array[Dictionary]) -> void:
	menu_mode = "weapon_select"
	build_menu("ARMORY", str(hero["name"]) + " SELECT YOUR PRIMARY WEAPON")
	for index in range(weapons.size()):
		var weapon: Dictionary = weapons[index]
		var is_special: bool = bool(weapon.get("is_special", false))
		var detail := str(weapon["tag"]) + "  |  DMG " + str(int(weapon["damage"])) + "  |  MAG " + str(weapon["magazine"])
		var title := str(weapon["name"]) + "  [SPECIAL]" if is_special else str(weapon["name"])
		var button := add_option(title, detail, weapon["color"])
		button.pressed.connect(emit_weapon_selected.bind(index))

func show_end_screen(won: bool, kills: int, elapsed: float) -> void:
	menu_mode = "end"
	set_hud_visible(false)
	var title := "DISTRICT SECURED" if won else "OPERATIVE DOWN"
	var detail := "HOSTILES ELIMINATED: %02d   TIME: %02d:%02d" % [kills, int(elapsed) / 60, int(elapsed) % 60]
	build_menu(title, detail)
	var button := add_option("RETURN TO OPERATIVE SELECT", "Choose another specialist or weapon loadout", Color("8eeeff"))
	button.pressed.connect(emit_menu_requested)

func show_pause(_settings: Variant) -> void:
	menu_mode = "pause"
	build_menu("PAUSED", "THE ARENA IS FROZEN")
	var resume := add_option("RESUME", "Return to the match", Color("70ffd0"))
	resume.pressed.connect(emit_resume_requested)
	var restart := add_option("RESTART MATCH", "Restart with your current loadout", Color("ffd35e"))
	restart.pressed.connect(emit_restart_requested)
	var loadout := add_option("CHANGE LOADOUT", "Return to operative and weapon selection", Color("8eeeff"))
	loadout.pressed.connect(emit_loadout_requested)
	var settings_button := add_option("SETTINGS", "Controls, video, and audio", Color("d58aff"))
	settings_button.pressed.connect(emit_settings_requested)

func show_settings(settings: Variant) -> void:
	menu_mode = "settings"
	build_menu("SETTINGS", "CHANGES APPLY IMMEDIATELY")
	add_slider("MOUSE SENSITIVITY", settings.mouse_sensitivity, 0.3, 3.0, 0.1, "mouse_sensitivity")
	add_slider("FIELD OF VIEW", settings.field_of_view, 60.0, 110.0, 1.0, "field_of_view")
	add_slider("MASTER VOLUME", settings.master_volume_db, -40.0, 0.0, 1.0, "master_volume", " dB")
	var fullscreen := CheckButton.new()
	fullscreen.text = "FULLSCREEN"
	fullscreen.button_pressed = settings.fullscreen
	fullscreen.add_theme_font_size_override("font_size", 16)
	fullscreen.toggled.connect(emit_fullscreen_changed)
	menu.add_child(fullscreen)
	var back := add_option("BACK", "Return to pause menu", Color("8eeeff"))
	back.pressed.connect(emit_settings_back_requested)

func emit_character_selected(index: int) -> void:
	character_selected.emit(index)

func emit_weapon_selected(index: int) -> void:
	weapon_selected.emit(index)

func emit_menu_requested() -> void:
	menu_requested.emit()

func highlight_character(index: int) -> void:
	highlighted_character = index
	for card_index in range(selection_cards.size()):
		selection_cards[card_index].set_selected(card_index == index)
	var hero: Dictionary = roster[index]
	var special: Dictionary = hero["special_weapon"]
	selection_detail.text = str(hero["role"]) + "\n" + str(hero["ability"]) + " - " + str(hero["description"]) + "\nSPECIAL WEAPON: " + str(special["name"]) + "  /  " + str(special["tag"]) + "  /  DMG " + str(int(special["damage"]))
	confirm_character.text = "CONTINUE AS " + str(hero["name"])
	confirm_character.add_theme_color_override("font_color", hero["accent"])

func confirm_highlighted_character() -> void:
	character_selected.emit(highlighted_character)

func emit_resume_requested() -> void:
	resume_requested.emit()

func emit_restart_requested() -> void:
	restart_requested.emit()

func emit_loadout_requested() -> void:
	loadout_requested.emit()

func emit_settings_requested() -> void:
	settings_requested.emit()

func emit_settings_back_requested() -> void:
	settings_back_requested.emit()

func emit_fullscreen_changed(value: bool) -> void:
	fullscreen_changed.emit(value)

func build_menu(title: String, subtitle: String) -> void:
	clear_menu()
	clear_character_screen()
	menu = VBoxContainer.new()
	menu.set_anchors_preset(Control.PRESET_CENTER)
	menu.position = Vector2(-265, -290)
	menu.size = Vector2(530, 580)
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

func clear_menu() -> void:
	if menu != null:
		menu.queue_free()
		menu = null

func clear_character_screen() -> void:
	if character_screen != null:
		character_screen.queue_free()
		character_screen = null
	selection_cards.clear()

func make_screen_label(value: String, at: Vector2, dimensions: Vector2, font_size: int, color: Color) -> Label:
	var label := Label.new()
	label.text = value
	label.position = at
	label.size = dimensions
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	return label

func add_option(title: String, detail: String, color: Color) -> Button:
	var button := Button.new()
	button.text = title + "\n" + detail
	button.custom_minimum_size = Vector2(530, 82)
	button.add_theme_font_size_override("font_size", 17)
	button.add_theme_color_override("font_color", color)
	menu.add_child(button)
	return button

func add_slider(title: String, value: float, minimum: float, maximum: float, step: float, setting: String, suffix: String = "") -> void:
	var row := HBoxContainer.new()
	row.custom_minimum_size = Vector2(530, 36)
	var label := Label.new()
	label.text = title
	label.custom_minimum_size = Vector2(175, 0)
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 14)
	row.add_child(label)
	var slider := HSlider.new()
	slider.min_value = minimum
	slider.max_value = maximum
	slider.step = step
	slider.value = value
	slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(slider)
	var value_label := Label.new()
	value_label.custom_minimum_size = Vector2(62, 0)
	value_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	value_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	value_label.text = "%.1f%s" % [value, suffix]
	row.add_child(value_label)
	slider.value_changed.connect(handle_slider_changed.bind(setting, value_label, suffix))
	menu.add_child(row)

func set_hud_visible(value: bool) -> void:
	overlay.visible = value

func show_game_hud() -> void:
	clear_menu()
	clear_character_screen()
	set_hud_visible(true)
	menu_mode = ""

func update_hud(health: float, weapon: Dictionary, ammo: int, reserve: int, ability: Dictionary, ability_time: float, cooldown: float, kills: int, target_kills: int, mana: float = -1.0) -> void:
	health_label.text = "HEALTH  %03d" % int(maxf(0.0, health))
	ammo_label.text = str(weapon["name"]).to_upper() + "\n%02d / %03d" % [ammo, reserve]
	var status := "READY" if cooldown == 0.0 else "%.1fs" % cooldown
	if ability_time > 0.0:
		status = "ACTIVE  %.1fs" % ability_time
	ability_label.text = "[Q] " + str(ability["ability"]) + "   " + status
	if str(ability["ability_effect"]) == "mana_blast":
		ability_label.text += "   MANA %03d" % int(mana)
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

func _input(event: InputEvent) -> void:
	if not (event is InputEventKey and event.pressed and not event.echo):
		return
	if event.keycode != KEY_ESCAPE:
		return
	if menu_mode == "pause":
		resume_requested.emit()
	elif menu_mode == "settings":
		settings_back_requested.emit()

func handle_slider_changed(value: float, setting: String, value_label: Label, suffix: String) -> void:
	value_label.text = "%.1f%s" % [value, suffix]
	if setting == "mouse_sensitivity":
		mouse_sensitivity_changed.emit(value)
	elif setting == "field_of_view":
		field_of_view_changed.emit(value)
	elif setting == "master_volume":
		master_volume_changed.emit(value)
