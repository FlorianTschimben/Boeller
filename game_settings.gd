class_name GameSettings
extends RefCounted

const PATH := "user://settings.cfg"

var mouse_sensitivity: float = 1.0
var field_of_view: float = 78.0
var master_volume_db: float = 0.0
var fullscreen: bool = false

func load_from_disk() -> void:
	var config := ConfigFile.new()
	if config.load(PATH) != OK:
		return
	mouse_sensitivity = float(config.get_value("controls", "mouse_sensitivity", mouse_sensitivity))
	field_of_view = float(config.get_value("video", "field_of_view", field_of_view))
	master_volume_db = float(config.get_value("audio", "master_volume_db", master_volume_db))
	fullscreen = bool(config.get_value("video", "fullscreen", fullscreen))

func save_to_disk() -> void:
	var config := ConfigFile.new()
	config.set_value("controls", "mouse_sensitivity", mouse_sensitivity)
	config.set_value("video", "field_of_view", field_of_view)
	config.set_value("audio", "master_volume_db", master_volume_db)
	config.set_value("video", "fullscreen", fullscreen)
	config.save(PATH)

func apply_display_and_audio() -> void:
	var master_bus := AudioServer.get_bus_index("Master")
	AudioServer.set_bus_volume_db(master_bus if master_bus >= 0 else 0, master_volume_db)
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN if fullscreen else DisplayServer.WINDOW_MODE_WINDOWED)
