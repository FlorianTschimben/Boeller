class_name ShotTracer
extends MeshInstance3D

const Data = preload("res://game_data.gd")

var remaining_life: float = 0.06

func setup(from: Vector3, to: Vector3, color: Color) -> void:
	var direction := to - from
	if direction.length() < 0.01:
		queue_free()
		return
	var cylinder := CylinderMesh.new()
	cylinder.top_radius = 0.018
	cylinder.bottom_radius = 0.018
	cylinder.height = direction.length()
	mesh = cylinder
	material_override = Data.material(color, 5.0)
	position = from.lerp(to, 0.5)
	basis = Basis(Quaternion(Vector3.UP, direction.normalized()))

func _process(delta: float) -> void:
	remaining_life -= delta
	if remaining_life <= 0.0:
		queue_free()
