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
		{
			"name": "VANGUARD", "role": "FRONTLINE BULWARK", "ability": "OVERDRIVE", "description": "Immortal for 5 seconds", "duration": 5.0, "cooldown": 18.0,
			"color": Color("60dfff"), "accent": Color("d9fbff"), "portrait_style": "armored", "symbol": "V",
			"special_weapon": {"name": "Aegis Cannon", "tag": "VANGUARD SPECIAL", "damage": 62.0, "fire_rate": 0.65, "magazine": 6, "reserve": 30, "reload_time": 1.9, "color": Color("60dfff"), "automatic": false, "spread": 0.012, "model_size": Vector3(0.28, 0.22, 0.92)}
		},
		{
			"name": "RAPID", "role": "MOBILE ASSAULT", "ability": "BOTTOMLESS", "description": "Unlimited ammunition for 7 seconds", "duration": 7.0, "cooldown": 20.0,
			"color": Color("ffd45f"), "accent": Color("fff4b3"), "portrait_style": "runner", "symbol": "R",
			"special_weapon": {"name": "Volt SMG", "tag": "RAPID SPECIAL", "damage": 17.0, "fire_rate": 0.052, "magazine": 48, "reserve": 192, "reload_time": 1.35, "color": Color("ffd45f"), "automatic": true, "spread": 0.028, "model_size": Vector3(0.19, 0.14, 0.68)}
		},
		{
			"name": "SPECTRE", "role": "RECON MARKSMAN", "ability": "PULSE SIGHT", "description": "Reveal nearest enemy through walls for 6 seconds", "duration": 6.0, "cooldown": 16.0,
			"color": Color("d58aff"), "accent": Color("f0d8ff"), "portrait_style": "hooded", "symbol": "S",
			"special_weapon": {"name": "Ghost Rail", "tag": "SPECTRE SPECIAL", "damage": 92.0, "fire_rate": 0.95, "magazine": 4, "reserve": 24, "reload_time": 2.15, "color": Color("d58aff"), "automatic": false, "spread": 0.002, "model_size": Vector3(0.14, 0.13, 1.08)}
		}
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
