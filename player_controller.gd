class_name ArenaPlayer
extends CharacterBody3D

const Data = preload("res://game_data.gd")

signal fire_requested
signal reload_requested
signal ability_requested
signal menu_requested

const SPEED: float = 7.5
const JUMP_VELOCITY: float = 7.2
const GRAVITY: float = 20.0

var camera: Camera3D
var ability_light: OmniLight3D
var weapon_mount: Node3D
var weapon_model: MeshInstance3D
var automatic_weapon: bool = false
var is_active: bool = false
var mouse_sensitivity: float = 1.0
var speed_multiplier: float = 1.0
var grapple_target: Vector3 = Vector3.ZERO
var is_grappling: bool = false
var yaw: float = 0.0
var pitch: float = 0.0

func setup() -> void:
	collision_layer = 0
	collision_mask = 1
	var collider := CollisionShape3D.new()
	var shape := CapsuleShape3D.new()
	shape.radius = 0.42
	shape.height = 1.8
	collider.shape = shape
	collider.position.y = 0.9
	add_child(collider)
	camera = Camera3D.new()
	camera.position = Vector3(0, 1.52, 0)
	camera.current = true
	camera.fov = 78.0
	add_child(camera)
	ability_light = OmniLight3D.new()
	ability_light.position = Vector3(0, 1.0, 0)
	ability_light.light_energy = 4.5
	ability_light.omni_range = 7.0
	ability_light.visible = false
	is_grappling = false
	add_child(ability_light)
	weapon_mount = Node3D.new()
	camera.add_child(weapon_mount)

func configure_weapon(loadout: Dictionary) -> void:
	automatic_weapon = bool(loadout["automatic"])
	for child in weapon_mount.get_children():
		child.queue_free()
	weapon_model = MeshInstance3D.new()
	var body_mesh := BoxMesh.new()
	body_mesh.size = loadout["model_size"]
	weapon_model.mesh = body_mesh
	weapon_model.material_override = Data.material(loadout["color"], 0.35)
	weapon_model.position = Vector3(0.42, -0.36, -0.82)
	weapon_model.rotation_degrees = Vector3(-4, -6, 0)
	weapon_mount.add_child(weapon_model)
	var grip := MeshInstance3D.new()
	var grip_mesh := BoxMesh.new()
	grip_mesh.size = Vector3(0.12, 0.30, 0.15)
	grip.mesh = grip_mesh
	grip.material_override = Data.material(Color("18242b"))
	grip.position = Vector3(0.42, -0.53, -0.60)
	weapon_mount.add_child(grip)

func reset_for_match(spawn_position: Vector3) -> void:
	position = spawn_position
	velocity = Vector3.ZERO
	rotation = Vector3.ZERO
	camera.rotation = Vector3.ZERO
	yaw = 0.0
	pitch = 0.0
	ability_light.visible = false

func set_active(value: bool) -> void:
	is_active = value
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED if value else Input.MOUSE_MODE_VISIBLE

func set_mouse_sensitivity(value: float) -> void:
	mouse_sensitivity = value

func set_field_of_view(value: float) -> void:
	camera.fov = value

func set_speed_multiplier(value: float) -> void:
	speed_multiplier = value

func set_ability_effect(active: bool, color: Color) -> void:
	ability_light.light_color = color
	ability_light.visible = active

func muzzle_position() -> Vector3:
	return camera.to_global(Vector3(0.42, -0.36, -1.18))

func aim_direction() -> Vector3:
	return -camera.global_transform.basis.z

func add_recoil() -> void:
	if weapon_model != null:
		weapon_model.position.z = -0.72

func dash_forward(distance: float) -> void:
	var direction := aim_direction()
	direction.y = 0.0
	if direction.length() > 0.01:
		move_and_collide(direction.normalized() * distance)

func teleport_to(destination: Vector3) -> void:
	position = destination
	velocity = Vector3.ZERO
	is_grappling = false

func grapple_to(destination: Vector3) -> void:
	grapple_target = destination
	is_grappling = true

func _input(event: InputEvent) -> void:
	if not is_active:
		return
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		yaw -= event.relative.x * 0.0025 * mouse_sensitivity
		pitch = clampf(pitch - event.relative.y * 0.0025 * mouse_sensitivity, -1.25, 1.25)
		rotation.y = yaw
		camera.rotation.x = pitch
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed and not automatic_weapon:
		fire_requested.emit()
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_Q:
			ability_requested.emit()
		elif event.keycode == KEY_R:
			reload_requested.emit()
		elif event.keycode == KEY_ESCAPE:
			menu_requested.emit()

func _physics_process(delta: float) -> void:
	if not is_active:
		return
	if is_grappling:
		var to_target: Vector3 = grapple_target - global_position
		if to_target.length() < 1.2:
			is_grappling = false
			velocity = Vector3.ZERO
		else:
			velocity = to_target.normalized() * 28.0
			move_and_slide()
		return
	var movement := Vector3.ZERO
	if Input.is_key_pressed(KEY_W): movement.z -= 1.0
	if Input.is_key_pressed(KEY_S): movement.z += 1.0
	if Input.is_key_pressed(KEY_A): movement.x -= 1.0
	if Input.is_key_pressed(KEY_D): movement.x += 1.0
	var local_move: Vector3 = movement.normalized() if movement.length() > 0.0 else Vector3.ZERO
	var world_move: Vector3 = global_transform.basis * local_move
	if is_on_floor():
		if Input.is_key_pressed(KEY_SPACE):
			velocity.y = JUMP_VELOCITY
	else:
		velocity.y -= GRAVITY * delta
	velocity.x = world_move.x * SPEED * speed_multiplier
	velocity.z = world_move.z * SPEED * speed_multiplier
	move_and_slide()
	if automatic_weapon and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		fire_requested.emit()
	if weapon_model != null:
		weapon_model.position.z = lerpf(weapon_model.position.z, -0.82, delta * 18.0)
