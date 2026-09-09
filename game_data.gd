class_name GameData
extends RefCounted

static func weapons() -> Array[Dictionary]:
	return [
		{"name": "Pistol", "tag": "PRECISION SIDEARM", "damage": 34.0, "fire_rate": 0.30, "magazine": 12, "reserve": 60, "reload_time": 1.05, "color": Color("64ddff"), "automatic": false, "spread": 0.008, "model_size": Vector3(0.16, 0.12, 0.52)},
		{"name": "Machine Gun", "tag": "SUPPRESSION", "damage": 13.0, "fire_rate": 0.075, "magazine": 40, "reserve": 160, "reload_time": 1.7, "color": Color("ffd35e"), "automatic": true, "spread": 0.035, "model_size": Vector3(0.20, 0.16, 0.86)},
		{"name": "AK-47", "tag": "HIGH IMPACT RIFLE", "damage": 24.0, "fire_rate": 0.13, "magazine": 30, "reserve": 120, "reload_time": 1.45, "color": Color("ff826e"), "automatic": true, "spread": 0.016, "model_size": Vector3(0.18, 0.14, 0.76)}
	]

static func characters() -> Array[Dictionary]:
	return [
		{"name": "VANGUARD", "ability": "OVERDRIVE", "description": "Immortal for 5 seconds", "duration": 5.0, "cooldown": 18.0, "color": Color("60dfff")},
		{"name": "RAPID", "ability": "BOTTOMLESS", "description": "Unlimited ammunition for 7 seconds", "duration": 7.0, "cooldown": 20.0, "color": Color("ffd45f")},
		{"name": "SPECTRE", "ability": "PULSE SIGHT", "description": "Reveal nearest enemy through walls for 6 seconds", "duration": 6.0, "cooldown": 16.0, "color": Color("d58aff")}
	]

static func material(color: Color, emission_strength: float = 0.0) -> StandardMaterial3D:
	var result := StandardMaterial3D.new()
	result.albedo_color = color
	result.metallic = 0.25
	result.roughness = 0.62
	if emission_strength > 0.0:
		result.emission_enabled = true
		result.emission = color
		result.emission_energy_multiplier = emission_strength
	return result
