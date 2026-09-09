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
			"name": "DUCE", "role": "HEAVY GUNNER", "ability": "VERHAERTEN", "ability_effect": "invulnerable", "description": "Become immortal for a short time", "duration": 5.0, "cooldown": 18.0,
			"color": Color("b7c9d3"), "accent": Color("f2fbff"), "portrait_style": "armored", "symbol": "D",
			"special_weapon": {"name": "Minigun", "tag": "DUCE SPECIAL", "damage": 11.0, "fire_rate": 0.045, "magazine": 100, "reserve": 300, "reload_time": 3.2, "color": Color("b7c9d3"), "automatic": true, "spread": 0.052, "model_size": Vector3(0.32, 0.25, 1.0)}
		},
		{
			"name": "MOCK", "role": "WORKSHOP DISRUPTOR", "ability": "MAKITA RADIO", "ability_effect": "slow", "description": "Slow every enemy in the arena", "duration": 6.0, "cooldown": 20.0,
			"color": Color("ffd45f"), "accent": Color("fff4b3"), "portrait_style": "runner", "symbol": "M",
			"special_weapon": {"name": "Motorsaw", "tag": "MOCK SPECIAL", "damage": 35.0, "fire_rate": 0.12, "magazine": 0, "reserve": 0, "reload_time": 0.0, "color": Color("ffd45f"), "automatic": true, "spread": 0.0, "range": 4.5, "weapon_effect": "melee", "uses_ammo": false, "model_size": Vector3(0.24, 0.20, 0.78)}
		},
		{
			"name": "FLO", "role": "LASER SCOUT", "ability": "TELEPORT", "ability_effect": "teleport", "description": "Teleport forward through the arena", "duration": 0.15, "cooldown": 14.0,
			"color": Color("d58aff"), "accent": Color("f0d8ff"), "portrait_style": "hooded", "symbol": "F",
			"special_weapon": {"name": "Lasergun", "tag": "FLO SPECIAL", "damage": 55.0, "fire_rate": 0.32, "magazine": 16, "reserve": 80, "reload_time": 1.4, "color": Color("d58aff"), "automatic": false, "spread": 0.001, "model_size": Vector3(0.15, 0.13, 0.96)}
		},
		{
			"name": "FBI", "role": "FIELD COMMAND", "ability": "FBI AGENTS", "ability_effect": "agents", "description": "Deploy mini robots that fight for you", "duration": 12.0, "cooldown": 24.0,
			"color": Color("63b7ff"), "accent": Color("d9efff"), "portrait_style": "medic", "symbol": "F",
			"special_weapon": {"name": "Grappling Hook", "tag": "FBI SPECIAL", "damage": 0.0, "fire_rate": 0.75, "magazine": 0, "reserve": 0, "reload_time": 0.0, "color": Color("63b7ff"), "automatic": false, "spread": 0.0, "range": 26.0, "weapon_effect": "grapple", "uses_ammo": false, "model_size": Vector3(0.15, 0.13, 0.88)}
		},
		{
			"name": "BENNI", "role": "STICKY HUNTER", "ability": "LIFESTEAL", "ability_effect": "lifesteal", "description": "Recover health from weapon damage", "duration": 8.0, "cooldown": 20.0,
			"color": Color("ff805d"), "accent": Color("ffe0c7"), "portrait_style": "demolition", "symbol": "B",
			"special_weapon": {"name": "Sticky Grenade Launcher", "tag": "BENNI SPECIAL", "damage": 74.0, "fire_rate": 0.65, "magazine": 6, "reserve": 36, "reload_time": 1.9, "color": Color("ff805d"), "automatic": false, "spread": 0.035, "weapon_effect": "sticky_grenade", "explosion_radius": 4.5, "projectile_speed": 22.0, "model_size": Vector3(0.28, 0.22, 0.88)}
		},
		{
			"name": "SIMON KRANZER", "role": "BUNDESKANZLER", "ability": "MINI PANZER", "ability_effect": "tank", "description": "Deploy a mini tank to fight for you", "duration": 14.0, "cooldown": 26.0,
			"color": Color("7f9dff"), "accent": Color("dce5ff"), "portrait_style": "striker", "symbol": "S",
			"special_weapon": {"name": "Rocket Launcher", "tag": "SIMON SPECIAL", "damage": 110.0, "fire_rate": 1.05, "magazine": 3, "reserve": 18, "reload_time": 2.3, "color": Color("7f9dff"), "automatic": false, "spread": 0.015, "weapon_effect": "rocket", "explosion_radius": 5.5, "projectile_speed": 36.0, "model_size": Vector3(0.26, 0.20, 1.04)}
		},
		{
			"name": "FABIAN", "role": "CITRUS ALCHEMIST", "ability": "LEMON TREE", "ability_effect": "lemon_tree", "description": "Plant a tree that heals friends and hurts enemies", "duration": 10.0, "cooldown": 24.0,
			"color": Color("d6e94c"), "accent": Color("f8ffd0"), "portrait_style": "hooded", "symbol": "F",
			"special_weapon": {"name": "Lemonator", "tag": "FABIAN SPECIAL", "damage": 26.0, "fire_rate": 0.14, "magazine": 30, "reserve": 150, "reload_time": 1.45, "color": Color("d6e94c"), "automatic": true, "spread": 0.02, "model_size": Vector3(0.19, 0.15, 0.78)}
		},
		{
			"name": "STOAN", "role": "ROAD ROLLER", "ability": "ROLLING STOAN", "ability_effect": "rolling_stone", "description": "Roll a giant stone down the street", "duration": 0.15, "cooldown": 22.0,
			"color": Color("9b8d7d"), "accent": Color("e3d8c8"), "portrait_style": "armored", "symbol": "S",
			"special_weapon": {"name": "Stoanschleider", "tag": "STOAN SPECIAL", "damage": 64.0, "fire_rate": 0.62, "magazine": 7, "reserve": 42, "reload_time": 1.8, "color": Color("9b8d7d"), "automatic": false, "spread": 0.022, "model_size": Vector3(0.25, 0.20, 0.84)}
		},
		{
			"name": "MARIAN", "role": "CRYO PILOT", "ability": "ICE LOCK", "ability_effect": "freeze", "description": "Freeze enemies and make them invulnerable", "duration": 6.0, "cooldown": 20.0,
			"color": Color("70e6ff"), "accent": Color("d8fbff"), "portrait_style": "runner", "symbol": "M",
			"special_weapon": {"name": "Lenkrakete", "tag": "MARIAN SPECIAL", "damage": 88.0, "fire_rate": 0.82, "magazine": 4, "reserve": 24, "reload_time": 2.0, "color": Color("70e6ff"), "automatic": false, "spread": 0.006, "model_size": Vector3(0.23, 0.18, 0.94)}
		},
		{
			"name": "MANUEL", "role": "RGB TECHNICIAN", "ability": "RGB OVERLOAD", "ability_effect": "mana_blast", "description": "Spend 50 mana to damage every enemy", "duration": 0.15, "cooldown": 16.0,
			"color": Color("ff5f72"), "accent": Color("f5f5ff"), "portrait_style": "striker", "symbol": "M",
			"special_weapon": {"name": "RGB LED Strips", "tag": "MANUEL SPECIAL", "damage": 24.0, "fire_rate": 0.11, "magazine": 36, "reserve": 180, "reload_time": 1.4, "color": Color("ff5f72"), "automatic": true, "spread": 0.018, "weapon_effect": "rgb", "model_size": Vector3(0.16, 0.12, 0.92)}
		},
		{
			"name": "ALAN", "role": "BOMB RUNNER", "ability": "BOOSTEN", "ability_effect": "boost", "description": "Boost movement and fire rate", "duration": 7.0, "cooldown": 18.0,
			"color": Color("ffb75e"), "accent": Color("fff0cf"), "portrait_style": "demolition", "symbol": "A",
			"special_weapon": {"name": "Bomben", "tag": "ALAN SPECIAL", "damage": 82.0, "fire_rate": 0.75, "magazine": 5, "reserve": 30, "reload_time": 1.9, "color": Color("ffb75e"), "automatic": false, "spread": 0.04, "weapon_effect": "grenade", "explosion_radius": 4.8, "projectile_speed": 20.0, "model_size": Vector3(0.26, 0.22, 0.82)}
		},
		{
			"name": "DANNY", "role": "GATEKEEPER", "ability": "TELEPORTER", "ability_effect": "teleporter", "description": "Place a teleporter for a rapid return", "duration": 12.0, "cooldown": 20.0,
			"color": Color("b78aff"), "accent": Color("f0e4ff"), "portrait_style": "medic", "symbol": "D",
			"special_weapon": {"name": "Pumpgun", "tag": "DANNY SPECIAL", "damage": 68.0, "fire_rate": 0.72, "magazine": 8, "reserve": 48, "reload_time": 1.65, "color": Color("b78aff"), "automatic": false, "spread": 0.095, "range": 14.0, "model_size": Vector3(0.24, 0.19, 0.88)}
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
