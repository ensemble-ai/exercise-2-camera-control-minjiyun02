class_name PositionLockLerpCamera
extends CameraControllerBase

@export var follow_speed: float = 40.0
@export var catchup_speed: float = 20.0
@export var leash_distance: float = 20.0

func _ready() -> void:
	super()
	position = target.position

func _process(delta: float) -> void:
	if !current:
		return

	var distance_to_target = global_position.distance_to(target.global_position)
	var direction_to_target = (target.global_position - global_position).normalized()

	if distance_to_target > leash_distance:
		global_position = target.global_position - direction_to_target * leash_distance

	var speed: float
	if target.velocity.length() > 0:
		speed = follow_speed
	else:
		speed = catchup_speed

	position += direction_to_target * speed * delta

	if draw_camera_logic:
		draw_logic()

func draw_logic() -> void:
	var mesh_instance := MeshInstance3D.new()
	var immediate_mesh := ImmediateMesh.new()
	var material := ORMMaterial3D.new()

	mesh_instance.mesh = immediate_mesh
	mesh_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = Color.BLACK

	immediate_mesh.surface_begin(Mesh.PRIMITIVE_LINES, material)

	immediate_mesh.surface_add_vertex(Vector3(-2.5, 0, 0))
	immediate_mesh.surface_add_vertex(Vector3(2.5, 0, 0))

	immediate_mesh.surface_add_vertex(Vector3(0, 0, -2.5))
	immediate_mesh.surface_add_vertex(Vector3(0, 0, 2.5))

	immediate_mesh.surface_end()

	add_child(mesh_instance)
	mesh_instance.global_transform = Transform3D.IDENTITY
	mesh_instance.global_position = Vector3(position.x, target.global_position.y, position.z)

	await get_tree().process_frame
	mesh_instance.queue_free()
