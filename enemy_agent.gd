class_name ArenaEnemy
extends CharacterBody3D

const Data = preload("res://game_data.gd")

var health: float = 70.0
var fire_timer: float = 0.0
var strafe_direction: float = 1.0
var reveal_marker: MeshInstance3D
var slow_remaining: float = 0.0
var frozen_remaining: float = 0.0
var invulnerable_remaining: float = 0.0

func setup(random_source: RandomNumberGenerator) -> void:
	collision_layer = 0
	collision_mask = 1
	var mesh_instance := MeshInstance3D.new()
	var mesh := CapsuleMesh.new()
	mesh.radius = 0.48
	mesh.height = 1.8
	mesh_instance.mesh = mesh
	mesh_instance.material_override = Data.material(Color("d44558"), 0.15)
	mesh_instance.position.y = 0.9
	add_child(mesh_instance)
	var head := MeshInstance3D.new()
	var head_mesh := SphereMesh.new()
	head_mesh.radius = 0.30
	head_mesh.height = 0.60
	head.mesh = head_mesh
	head.material_override = Data.material(Color("ff9c83"), 0.05)
	head.position.y = 1.52
	add_child(head)
	var collider := CollisionShape3D.new()
	var shape := CapsuleShape3D.new()
	shape.radius = 0.48
	shape.height = 1.8
	collider.shape = shape
	collider.position.y = 0.9
	add_child(collider)
	var light := OmniLight3D.new()
	light.position.y = 1.2
	light.light_color = Color("ff4052")
	light.light_energy = 1.2
	light.omni_range = 4.0
	add_child(light)
	reveal_marker = MeshInstance3D.new()
	var marker_mesh := SphereMesh.new()
	marker_mesh.radius = 0.82
	marker_mesh.height = 1.64
	reveal_marker.mesh = marker_mesh
	var marker_material := Data.material(Color(0.84, 0.54, 1.0, 0.42), 2.0)
	marker_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	marker_material.no_depth_test = true
	reveal_marker.material_override = marker_material
	reveal_marker.position.y = 0.9
	reveal_marker.visible = false
	add_child(reveal_marker)
	fire_timer = random_source.randf_range(0.3, 1.0)
	strafe_direction = random_source.randf_range(-1.0, 1.0)

func update_behavior(target: Vector3, delta: float, blocked: Callable) -> bool:
	slow_remaining = maxf(0.0, slow_remaining - delta)
	frozen_remaining = maxf(0.0, frozen_remaining - delta)
	invulnerable_remaining = maxf(0.0, invulnerable_remaining - delta)
	if frozen_remaining > 0.0:
		return false
	var flat_target := target
	flat_target.y = position.y
	var to_target: Vector3 = flat_target - position
	var distance: float = to_target.length()
	if distance > 7.5:
		var speed_multiplier: float = 0.38 if slow_remaining > 0.0 else 1.0
		var candidate := position + to_target.normalized() * 2.15 * speed_multiplier * delta
		if not blocked.call(candidate):
			position = candidate
	elif distance > 0.2:
		var strafe_speed: float = 0.38 if slow_remaining > 0.0 else 1.0
		var strafe := to_target.normalized().cross(Vector3.UP) * strafe_direction * 1.6 * strafe_speed * delta
		if not blocked.call(position + strafe):
			position += strafe
	if distance > 0.2:
		look_at(flat_target, Vector3.UP, true)
	fire_timer -= delta
	if fire_timer <= 0.0:
		fire_timer = 0.0
		return true
	return false

func reset_fire_timer(random_source: RandomNumberGenerator) -> void:
	fire_timer = random_source.randf_range(0.75, 1.25)

func apply_damage(amount: float) -> float:
	if invulnerable_remaining > 0.0:
		return 0.0
	var dealt: float = minf(amount, health)
	health -= dealt
	return dealt

func is_dead() -> bool:
	return health <= 0.0

func apply_status(effect: String, duration: float) -> void:
	if effect == "slow":
		slow_remaining = maxf(slow_remaining, duration)
	elif effect == "freeze":
		frozen_remaining = maxf(frozen_remaining, duration)
		invulnerable_remaining = maxf(invulnerable_remaining, duration)

func set_revealed(value: bool) -> void:
	reveal_marker.visible = value
