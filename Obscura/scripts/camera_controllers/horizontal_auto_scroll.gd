class_name HorizontalAutoScroll
extends CameraControllerBase

@export var top_left: Vector2
@export var bottom_right: Vector2
@export var autoscroll_speed: Vector3 = Vector3(2, 0, 0)

func _ready() -> void:
	super()
	position = target.position

func _process(delta: float) -> void:
	if !current:
		return

	super(delta)
	
	position.x += autoscroll_speed.x * delta
	position.z += autoscroll_speed.z * delta
	
	if target.global_position.x < position.x + top_left.x:
		target.global_position.x = position.x + top_left.x
	elif target.global_position.x > position.x + bottom_right.x:
		target.global_position.x = position.x + bottom_right.x

	if target.global_position.z < position.z + top_left.y:
		target.global_position.z = position.z + top_left.y
	elif target.global_position.z > position.z + bottom_right.y:
		target.global_position.z = position.z + bottom_right.y
		
	if draw_camera_logic:
		draw_logic()

func draw_logic() -> void:
	super()

	var mesh_instance := MeshInstance3D.new()
	var immediate_mesh := ImmediateMesh.new()
	var material := ORMMaterial3D.new()

	mesh_instance.mesh = immediate_mesh
	mesh_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = Color.BLACK

	immediate_mesh.surface_begin(Mesh.PRIMITIVE_LINES, material)

	var left = top_left.x
	var right = bottom_right.x
	var top = top_left.y
	var bottom = bottom_right.y

	immediate_mesh.surface_add_vertex(Vector3(right, 0, top))
	immediate_mesh.surface_add_vertex(Vector3(right, 0, bottom))

	immediate_mesh.surface_add_vertex(Vector3(right, 0, bottom))
	immediate_mesh.surface_add_vertex(Vector3(left, 0, bottom))

	immediate_mesh.surface_add_vertex(Vector3(left, 0, bottom))
	immediate_mesh.surface_add_vertex(Vector3(left, 0, top))

	immediate_mesh.surface_add_vertex(Vector3(left, 0, top))
	immediate_mesh.surface_add_vertex(Vector3(right, 0, top))

	immediate_mesh.surface_end()

	add_child(mesh_instance)
	mesh_instance.global_transform = Transform3D.IDENTITY
	mesh_instance.global_position = Vector3(global_position.x, target.global_position.y, global_position.z)

	await get_tree().process_frame
	mesh_instance.queue_free()
