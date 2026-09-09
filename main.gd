extends Node3D

const KILLS_TO_WIN: int = 25
const ARENA_LIMIT: float = 38.0
const HEADSHOT_MULTIPLIER: float = 2.0
const Data = preload("res://game_data.gd")
const PlayerController = preload("res://player_controller.gd")
const EnemyAgent = preload("res://enemy_agent.gd")
const TracerEffect = preload("res://shot_tracer.gd")
const HudController = preload("res://arena_hud.gd")
const SettingsStore = preload("res://game_settings.gd")

var default_weapons: Array[Dictionary] = Data.weapons()
var available_weapons: Array[Dictionary] = []
var characters: Array[Dictionary] = Data.characters()
var state: String = "character_select"
var selected_character: int = 0
var selected_weapon: int = 0
var player: Variant
var hud: Variant
var settings: Variant
var enemies: Array = []
var walls: Array[Dictionary] = []
var spawn_points: Array[Vector3] = []
var rng: RandomNumberGenerator = RandomNumberGenerator.new()
var player_health: float = 100.0
var ammo: int = 0
var reserve_ammo: int = 0
var kills: int = 0
var elapsed: float = 0.0
var reload_remaining: float = 0.0
var ability_remaining: float = 0.0
var ability_cooldown: float = 0.0
var fire_cooldown: float = 0.0
var mana: float = 100.0
var rgb_mode: int = 0
var companions: Array[Dictionary] = []
var tactical_zones: Array[Dictionary] = []
var rolling_stones: Array[Dictionary] = []
var teleporter: Node3D

func _ready() -> void:
	rng.seed = 47012
	settings = SettingsStore.new()
	settings.load_from_disk()
	settings.apply_display_and_audio()
	build_environment()
	build_arena()
	build_player()
	build_hud()
	show_character_selection()

func build_environment() -> void:
	var environment := Environment.new()
	environment.background_mode = Environment.BG_COLOR
	environment.background_color = Color("07131d")
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color("78a7bc")
	environment.ambient_light_energy = 0.55
	environment.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	environment.glow_enabled = true
	environment.glow_intensity = 1.1
	environment.fog_enabled = true
	environment.fog_light_color = Color("203c4a")
	environment.fog_density = 0.012
	var world_environment := WorldEnvironment.new()
	world_environment.environment = environment
	add_child(world_environment)
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-58, -34, 0)
	sun.light_color = Color("c9efff")
	sun.light_energy = 1.25
	sun.shadow_enabled = true
	add_child(sun)
	var plaza_light := OmniLight3D.new()
	plaza_light.position = Vector3(0, 8, 0)
	plaza_light.light_color = Color("37bbdb")
	plaza_light.light_energy = 8.0
	plaza_light.omni_range = 34.0
	add_child(plaza_light)

func build_arena() -> void:
	add_box(Vector3(0, -0.3, 0), Vector3(80, 0.6, 80), Color("172a32"), false)
	var structures: Array[Array] = [
		[Vector3(-13, 2.5, -13), Vector3(13, 5, 8)], [Vector3(13, 2.5, -13), Vector3(13, 5, 8)],
		[Vector3(-13, 2.5, 13), Vector3(13, 5, 8)], [Vector3(13, 2.5, 13), Vector3(13, 5, 8)],
		[Vector3(0, 2.0, 0), Vector3(10, 4, 8)], [Vector3(-29, 2.0, -28), Vector3(7, 4, 6)],
		[Vector3(29, 2.0, 28), Vector3(7, 4, 6)], [Vector3(-29, 1.4, 25), Vector3(8, 2.8, 3)],
		[Vector3(29, 1.4, -25), Vector3(8, 2.8, 3)]
	]
	for structure in structures:
		add_box(structure[0], structure[1], Color("263e48"), true)
	for cover in [Vector3(-22, 1, 0), Vector3(22, 1, 0), Vector3(-4, 1, -27), Vector3(5, 1, 27), Vector3(-28, 1, 10), Vector3(28, 1, -10)]:
		add_box(cover, Vector3(3.4, 2, 1.5), Color("49626b"), true)
	for x in range(-36, 37, 6):
		add_box(Vector3(float(x), 0.02, -38), Vector3(0.12, 0.05, 2.0), Color("54dcdf"), false, 2.0)
	spawn_points = [Vector3(-33, 0, -33), Vector3(33, 0, -31), Vector3(32, 0, 32), Vector3(-32, 0, 31), Vector3(-23, 0, 8), Vector3(24, 0, -7)]

func add_box(at: Vector3, size: Vector3, color: Color, blocks_movement: bool, emission: float = 0.0) -> void:
	var root: Node3D = StaticBody3D.new()
	root.position = at
	add_child(root)
	var mesh_instance := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = size
	mesh_instance.mesh = mesh
	mesh_instance.material_override = Data.material(color, emission)
	root.add_child(mesh_instance)
	var collider := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = size
	collider.shape = shape
	root.add_child(collider)
	if blocks_movement:
		walls.append({"center": at, "size": size})

func build_player() -> void:
	player = PlayerController.new()
	add_child(player)
	player.setup()
	player.set_mouse_sensitivity(settings.mouse_sensitivity)
	player.set_field_of_view(settings.field_of_view)
	player.fire_requested.connect(try_fire)
	player.reload_requested.connect(start_reload)
	player.ability_requested.connect(activate_ability)
	player.menu_requested.connect(toggle_pause)

func build_hud() -> void:
	hud = HudController.new()
	add_child(hud)
	hud.setup()
	hud.character_selected.connect(select_character)
	hud.weapon_selected.connect(select_weapon)
	hud.menu_requested.connect(show_character_selection)
	hud.resume_requested.connect(resume_match)
	hud.restart_requested.connect(restart_match)
	hud.loadout_requested.connect(show_character_selection)
	hud.settings_requested.connect(show_settings)
	hud.settings_back_requested.connect(show_pause_menu)
	hud.mouse_sensitivity_changed.connect(set_mouse_sensitivity)
	hud.field_of_view_changed.connect(set_field_of_view)
	hud.master_volume_changed.connect(set_master_volume)
	hud.fullscreen_changed.connect(set_fullscreen)

func show_character_selection() -> void:
	get_tree().paused = false
	state = "character_select"
	player.set_active(false)
	hud.show_character_selection(characters, selected_character)

func select_character(index: int) -> void:
	selected_character = index
	state = "weapon_select"
	available_weapons = build_loadout(characters[index])
	hud.show_weapon_selection(characters[index], available_weapons)

func select_weapon(index: int) -> void:
	selected_weapon = index
	player.configure_weapon(available_weapons[index])
	start_match()

func build_loadout(character: Dictionary) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for weapon in default_weapons:
		result.append(weapon.duplicate(true))
	var special_weapon: Dictionary = character["special_weapon"].duplicate(true)
	special_weapon["is_special"] = true
	result.append(special_weapon)
	return result

func start_match() -> void:
	get_tree().paused = false
	state = "playing"
	clear_enemies()
	clear_deployables()
	player.reset_for_match(Vector3(-33, 0, 0))
	player.set_active(true)
	player_health = 100.0
	kills = 0
	elapsed = 0.0
	reload_remaining = 0.0
	ability_remaining = 0.0
	ability_cooldown = 0.0
	fire_cooldown = 0.0
	mana = 100.0
	rgb_mode = 0
	var weapon: Dictionary = available_weapons[selected_weapon]
	ammo = int(weapon["magazine"])
	reserve_ammo = int(weapon["reserve"])
	for point in spawn_points:
		spawn_enemy(point)
	hud.show_game_hud()
	hud.show_message("ELIMINATE HOSTILES", 2.0)

func toggle_pause() -> void:
	if state == "playing":
		pause_match()
	elif state == "paused":
		resume_match()

func pause_match() -> void:
	state = "paused"
	player.set_active(false)
	hud.show_pause(settings)
	get_tree().paused = true

func resume_match() -> void:
	if state != "paused":
		return
	get_tree().paused = false
	state = "playing"
	player.set_active(true)
	hud.show_game_hud()

func restart_match() -> void:
	if state != "paused":
		return
	get_tree().paused = false
	start_match()

func show_pause_menu() -> void:
	if state == "paused":
		hud.show_pause(settings)

func show_settings() -> void:
	if state == "paused":
		hud.show_settings(settings)

func set_mouse_sensitivity(value: float) -> void:
	settings.mouse_sensitivity = value
	player.set_mouse_sensitivity(value)
	settings.save_to_disk()

func set_field_of_view(value: float) -> void:
	settings.field_of_view = value
	player.set_field_of_view(value)
	settings.save_to_disk()

func set_master_volume(value: float) -> void:
	settings.master_volume_db = value
	settings.apply_display_and_audio()
	settings.save_to_disk()

func set_fullscreen(value: bool) -> void:
	settings.fullscreen = value
	settings.apply_display_and_audio()
	settings.save_to_disk()

func clear_enemies() -> void:
	for enemy in enemies:
		enemy.queue_free()
	enemies.clear()

func spawn_enemy(spawn_position: Vector3) -> void:
	var enemy: Variant = EnemyAgent.new()
	enemy.position = spawn_position
	add_child(enemy)
	enemy.setup(rng)
	enemies.append(enemy)

func _process(delta: float) -> void:
	if state != "playing":
		return
	elapsed += delta
	update_timers(delta)
	update_enemies(delta)
	update_companions(delta)
	update_tactical_zones(delta)
	update_rolling_stones(delta)
	update_hud()
	if enemies.size() < 6 and kills < KILLS_TO_WIN:
		spawn_enemy(spawn_points[rng.randi_range(0, spawn_points.size() - 1)])
	if kills >= KILLS_TO_WIN:
		finish_match(true)

func update_timers(delta: float) -> void:
	fire_cooldown = maxf(0.0, fire_cooldown - delta)
	if reload_remaining > 0.0:
		reload_remaining = maxf(0.0, reload_remaining - delta)
		if reload_remaining == 0.0:
			finish_reload()
	ability_remaining = maxf(0.0, ability_remaining - delta)
	ability_cooldown = maxf(0.0, ability_cooldown - delta)
	var hero: Dictionary = characters[selected_character]
	player.set_ability_effect(ability_remaining > 0.0, hero["color"])
	player.set_speed_multiplier(1.45 if ability_remaining > 0.0 and current_ability_effect() == "boost" else 1.0)
	if current_ability_effect() == "mana_blast":
		mana = minf(100.0, mana + 10.0 * delta)

func update_enemies(delta: float) -> void:
	var nearest: Variant = nearest_enemy()
	var reveal_active: bool = ability_remaining > 0.0 and current_ability_effect() == "reveal"
	for enemy in enemies:
		var ready_to_fire: bool = enemy.update_behavior(player.global_position, delta, enemy_position_blocked)
		enemy.set_revealed(reveal_active and enemy == nearest)
		if ready_to_fire:
			handle_enemy_shot(enemy)

func handle_enemy_shot(enemy: Variant) -> void:
	enemy.reset_fire_timer(rng)
	var from: Vector3 = enemy.global_position + Vector3.UP
	var to: Vector3 = player.global_position + Vector3.UP
	if from.distance_to(to) >= 28.0 or not world_ray(from, to).is_empty():
		return
	spawn_tracer(from, to, Color("ff5361"))
	if ability_remaining > 0.0 and current_ability_effect() == "invulnerable":
		return
	var accuracy: float = clampf(0.86 - from.distance_to(to) * 0.012, 0.42, 0.86)
	if rng.randf() < accuracy:
		player_health -= rng.randf_range(7.0, 12.0)
		if player_health <= 0.0:
			finish_match(false)

func try_fire() -> void:
	if state != "playing" or fire_cooldown > 0.0 or reload_remaining > 0.0:
		return
	var unlimited_ammo: bool = ability_remaining > 0.0 and current_ability_effect() == "unlimited_ammo"
	if ammo <= 0 and not unlimited_ammo:
		start_reload()
		return
	var weapon: Dictionary = available_weapons[selected_weapon]
	var weapon_damage: float = float(weapon["damage"])
	if str(weapon.get("weapon_effect", "")) == "rgb":
		weapon_damage = apply_rgb_weapon_effect(weapon_damage)
	var from: Vector3 = player.muzzle_position()
	var direction: Vector3 = player.aim_direction()
	var spread: float = float(weapon["spread"])
	direction = direction.rotated(player.camera.global_transform.basis.y, rng.randf_range(-spread, spread))
	direction = direction.rotated(player.camera.global_transform.basis.x, rng.randf_range(-spread, spread))
	var maximum_distance: float = float(weapon.get("range", 80.0))
	var wall_hit: Dictionary = world_ray(from, from + direction * maximum_distance)
	if not wall_hit.is_empty():
		maximum_distance = from.distance_to(wall_hit["position"])
	var hit: Dictionary = find_target(from, direction, maximum_distance)
	if not hit.is_empty():
		var enemy: Variant = hit["enemy"]
		var is_headshot: bool = hit["headshot"]
		var impact: Vector3 = enemy.global_position + Vector3.UP * (1.52 if is_headshot else 0.9)
		spawn_tracer(from, impact, weapon["color"])
		var damage: float = weapon_damage * (HEADSHOT_MULTIPLIER if is_headshot else 1.0)
		var dealt: float = damage_enemy(enemy, damage, is_headshot)
		if current_ability_effect() == "lifesteal" and ability_remaining > 0.0:
			player_health = minf(100.0, player_health + dealt * 0.35)
		if dealt > 0.0 and is_headshot:
			hud.show_message("HEADSHOT", 0.45)
	else:
		spawn_tracer(from, from + direction * maximum_distance, weapon["color"])
	if not unlimited_ammo:
		ammo -= 1
	fire_cooldown = float(weapon["fire_rate"]) * (0.60 if ability_remaining > 0.0 and current_ability_effect() == "boost" else 1.0)
	player.add_recoil()
	if ammo <= 0 and not unlimited_ammo:
		start_reload()

func find_target(from: Vector3, direction: Vector3, maximum_distance: float) -> Dictionary:
	var hit: Dictionary = {}
	var closest_distance: float = maximum_distance
	for enemy in enemies:
		var enemy_center: Vector3 = enemy.global_position + Vector3.UP * 0.9
		var to_enemy: Vector3 = enemy_center - from
		var projected_distance: float = to_enemy.dot(direction)
		var miss_distance: float = (to_enemy - direction * projected_distance).length()
		var head_center: Vector3 = enemy.global_position + Vector3.UP * 1.52
		var to_head: Vector3 = head_center - from
		var head_miss_distance: float = (to_head - direction * to_head.dot(direction)).length()
		if projected_distance > 0.0 and projected_distance < closest_distance and miss_distance < 0.76:
			closest_distance = projected_distance
			hit = {"enemy": enemy, "headshot": head_miss_distance < 0.30}
	return hit

func start_reload() -> void:
	if reload_remaining > 0.0 or reserve_ammo <= 0 or ammo >= int(available_weapons[selected_weapon]["magazine"]):
		return
	reload_remaining = float(available_weapons[selected_weapon]["reload_time"])
	hud.show_message("RELOADING", 0.75)

func finish_reload() -> void:
	var needed: int = int(available_weapons[selected_weapon]["magazine"]) - ammo
	var loaded: int = mini(needed, reserve_ammo)
	ammo += loaded
	reserve_ammo -= loaded

func activate_ability() -> void:
	if ability_remaining > 0.0 or ability_cooldown > 0.0:
		return
	var hero: Dictionary = characters[selected_character]
	if str(hero["ability_effect"]) == "mana_blast" and mana < 50.0:
		hud.show_message("RGB OVERLOAD REQUIRES 50 MANA", 1.2)
		return
	ability_remaining = float(hero["duration"])
	ability_cooldown = float(hero["cooldown"])
	var message: String = str(hero["ability"]) + " ACTIVE"
	match str(hero["ability_effect"]):
		"slow":
			apply_status_to_all("slow", ability_remaining)
		"teleport":
			player.dash_forward(14.0)
		"agents":
			spawn_companions(3, false)
		"lifesteal":
			pass
		"tank":
			spawn_companions(1, true)
		"lemon_tree":
			spawn_lemon_tree()
		"rolling_stone":
			spawn_rolling_stone()
		"freeze":
			apply_status_to_all("freeze", ability_remaining)
		"mana_blast":
			mana -= 50.0
			message = "RGB OVERLOAD  %d TARGETS" % damage_all_enemies(55.0)
		"boost":
			pass
		"teleporter":
			message = place_or_use_teleporter()
	hud.show_message(message, 1.25)

func current_ability_effect() -> String:
	return str(characters[selected_character]["ability_effect"])

func apply_rgb_weapon_effect(base_damage: float) -> float:
	var result: float = base_damage
	if rgb_mode == 0:
		result *= 1.4
	elif rgb_mode == 1:
		player_health = minf(100.0, player_health + 4.0)
	else:
		mana = minf(100.0, mana + 12.0)
		player_health = maxf(1.0, player_health - 3.0)
	rgb_mode = (rgb_mode + 1) % 3
	return result

func damage_enemy(enemy: Variant, amount: float, was_headshot: bool = false) -> float:
	var dealt: float = enemy.apply_damage(amount)
	if enemy.is_dead():
		kill_enemy(enemy, was_headshot)
	return dealt

func apply_status_to_all(effect: String, duration: float) -> void:
	for enemy in enemies:
		enemy.apply_status(effect, duration)

func damage_all_enemies(amount: float) -> int:
	var targets: Array = enemies.duplicate()
	for enemy in targets:
		damage_enemy(enemy, amount)
	return targets.size()

func clear_deployables() -> void:
	for companion in companions:
		companion["node"].queue_free()
	companions.clear()
	for zone in tactical_zones:
		zone["node"].queue_free()
	tactical_zones.clear()
	for stone in rolling_stones:
		stone["node"].queue_free()
	rolling_stones.clear()
	if teleporter != null and is_instance_valid(teleporter):
		teleporter.queue_free()
	teleporter = null

func spawn_companions(count: int, is_tank: bool) -> void:
	for index in count:
		var node := Node3D.new()
		node.position = player.global_position + Vector3(float(index - count / 2) * 1.2, 0.4, -1.8)
		add_child(node)
		var mesh_instance := MeshInstance3D.new()
		var mesh := BoxMesh.new()
		mesh.size = Vector3(1.3, 0.75, 1.7) if is_tank else Vector3(0.55, 0.55, 0.55)
		mesh_instance.mesh = mesh
		mesh_instance.material_override = Data.material(Color("78c9ff") if not is_tank else Color("8b9b61"), 1.3)
		node.add_child(mesh_instance)
		var light := OmniLight3D.new()
		light.light_color = Color("78c9ff") if not is_tank else Color("d7ff73")
		light.light_energy = 1.5
		light.omni_range = 4.0
		node.add_child(light)
		companions.append({"node": node, "remaining": 12.0 if not is_tank else 14.0, "fire": 0.3, "damage": 12.0 if not is_tank else 35.0, "speed": 5.0 if not is_tank else 3.0, "range": 16.0 if not is_tank else 22.0})

func update_companions(delta: float) -> void:
	for index in range(companions.size() - 1, -1, -1):
		var companion: Dictionary = companions[index]
		companion["remaining"] = float(companion["remaining"]) - delta
		if float(companion["remaining"]) <= 0.0:
			companion["node"].queue_free()
			companions.remove_at(index)
			continue
		var node: Node3D = companion["node"]
		var target: Variant = nearest_enemy_to(node.global_position)
		if target != null:
			var distance: float = node.global_position.distance_to(target.global_position)
			if distance > 5.0:
				node.position += node.global_position.direction_to(target.global_position) * float(companion["speed"]) * delta
			companion["fire"] = float(companion["fire"]) - delta
			if float(companion["fire"]) <= 0.0 and distance < float(companion["range"]):
				companion["fire"] = 0.55 if float(companion["damage"]) < 20.0 else 0.9
				spawn_tracer(node.global_position, target.global_position + Vector3.UP * 0.9, Color("78c9ff"))
				damage_enemy(target, float(companion["damage"]))
		companions[index] = companion

func nearest_enemy_to(origin: Vector3) -> Variant:
	var target: Variant = null
	var closest: float = INF
	for enemy in enemies:
		var distance: float = origin.distance_to(enemy.global_position)
		if distance < closest:
			closest = distance
			target = enemy
	return target

func spawn_lemon_tree() -> void:
	var node := Node3D.new()
	node.position = player.global_position
	add_child(node)
	var trunk := MeshInstance3D.new()
	var trunk_mesh := CylinderMesh.new()
	trunk_mesh.top_radius = 0.18
	trunk_mesh.bottom_radius = 0.28
	trunk_mesh.height = 2.4
	trunk.mesh = trunk_mesh
	trunk.position.y = 1.2
	trunk.material_override = Data.material(Color("83683e"))
	node.add_child(trunk)
	var crown := MeshInstance3D.new()
	var crown_mesh := SphereMesh.new()
	crown_mesh.radius = 1.55
	crown_mesh.height = 3.1
	crown.mesh = crown_mesh
	crown.position.y = 3.0
	crown.material_override = Data.material(Color("d6e94c"), 0.6)
	node.add_child(crown)
	tactical_zones.append({"node": node, "remaining": 10.0, "radius": 7.0})

func update_tactical_zones(delta: float) -> void:
	for index in range(tactical_zones.size() - 1, -1, -1):
		var zone: Dictionary = tactical_zones[index]
		zone["remaining"] = float(zone["remaining"]) - delta
		if float(zone["remaining"]) <= 0.0:
			zone["node"].queue_free()
			tactical_zones.remove_at(index)
			continue
		var node: Node3D = zone["node"]
		var radius: float = float(zone["radius"])
		if player.global_position.distance_to(node.global_position) <= radius:
			player_health = minf(100.0, player_health + 9.0 * delta)
		for enemy in enemies.duplicate():
			if enemy.global_position.distance_to(node.global_position) <= radius:
				damage_enemy(enemy, 12.0 * delta)
		tactical_zones[index] = zone

func spawn_rolling_stone() -> void:
	var direction: Vector3 = player.aim_direction()
	direction.y = 0.0
	if direction.length() < 0.01:
		return
	var node := MeshInstance3D.new()
	var mesh := SphereMesh.new()
	mesh.radius = 1.25
	mesh.height = 2.5
	node.mesh = mesh
	node.material_override = Data.material(Color("9b8d7d"), 0.2)
	node.position = player.global_position + direction.normalized() * 2.0 + Vector3.UP * 1.25
	add_child(node)
	rolling_stones.append({"node": node, "direction": direction.normalized(), "remaining": 4.5})

func update_rolling_stones(delta: float) -> void:
	for index in range(rolling_stones.size() - 1, -1, -1):
		var stone: Dictionary = rolling_stones[index]
		var node: MeshInstance3D = stone["node"]
		stone["remaining"] = float(stone["remaining"]) - delta
		node.position += stone["direction"] * 15.0 * delta
		node.rotate_object_local(Vector3.RIGHT, 8.0 * delta)
		for enemy in enemies.duplicate():
			if enemy.global_position.distance_to(node.global_position) < 1.8:
				damage_enemy(enemy, 105.0)
		if float(stone["remaining"]) <= 0.0 or absf(node.position.x) > ARENA_LIMIT or absf(node.position.z) > ARENA_LIMIT:
			node.queue_free()
			rolling_stones.remove_at(index)
		else:
			rolling_stones[index] = stone

func place_or_use_teleporter() -> String:
	if teleporter != null and is_instance_valid(teleporter):
		player.teleport_to(teleporter.global_position + Vector3(0, 0, 1.5))
		teleporter.queue_free()
		teleporter = null
		return "TELEPORTER USED"
	var teleporter_mesh := MeshInstance3D.new()
	var mesh := CylinderMesh.new()
	mesh.top_radius = 0.7
	mesh.bottom_radius = 0.9
	mesh.height = 0.25
	teleporter_mesh.mesh = mesh
	teleporter_mesh.material_override = Data.material(Color("b78aff"), 2.0)
	teleporter_mesh.position = player.global_position + Vector3.UP * 0.13
	teleporter = teleporter_mesh
	add_child(teleporter_mesh)
	return "TELEPORTER PLACED"

func kill_enemy(enemy: Variant, was_headshot: bool = false) -> void:
	enemies.erase(enemy)
	enemy.queue_free()
	kills += 1
	hud.show_message("HEADSHOT ELIMINATION  +150" if was_headshot else "HOSTILE ELIMINATED  +100", 0.7)

func nearest_enemy() -> Variant:
	var nearest: Variant = null
	var shortest_distance: float = INF
	for enemy in enemies:
		var distance: float = enemy.global_position.distance_to(player.global_position)
		if distance < shortest_distance:
			shortest_distance = distance
			nearest = enemy
	return nearest

func enemy_position_blocked(test_position: Vector3) -> bool:
	if absf(test_position.x) > ARENA_LIMIT or absf(test_position.z) > ARENA_LIMIT:
		return true
	for wall in walls:
		var center: Vector3 = wall["center"]
		var size: Vector3 = wall["size"]
		if absf(test_position.x - center.x) < size.x * 0.5 + 0.6 and absf(test_position.z - center.z) < size.z * 0.5 + 0.6:
			return true
	return false

func world_ray(from: Vector3, to: Vector3) -> Dictionary:
	var query := PhysicsRayQueryParameters3D.create(from, to, 1)
	return get_world_3d().direct_space_state.intersect_ray(query)

func spawn_tracer(from: Vector3, to: Vector3, color: Color) -> void:
	var tracer: Variant = TracerEffect.new()
	tracer.setup(from, to, color)
	add_child(tracer)

func update_hud() -> void:
	hud.update_hud(player_health, available_weapons[selected_weapon], ammo, reserve_ammo, characters[selected_character], ability_remaining, ability_cooldown, kills, KILLS_TO_WIN, mana)

func finish_match(won: bool) -> void:
	state = "end"
	player.set_active(false)
	hud.show_end_screen(won, kills, elapsed)
