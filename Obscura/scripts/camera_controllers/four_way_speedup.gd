class_name FourWaySpeedupCamera
extends CameraControllerBase

@export var push_ratio: float = 0.5
@export var pushbox_top_left: Vector2
@export var pushbox_bottom_right: Vector2
@export var speedup_zone_top_left: Vector2
@export var speedup_zone_bottom_right: Vector2

func _ready() -> void:
	super()
	position = target.position

func _process(delta: float) -> void:
	if !current:
		return

	if draw_camera_logic:
		draw_logic()

	var target_position = target.global_position
	var velocity = target.velocity

	var in_speedup_zone = is_in_zone(target_position, speedup_zone_top_left, speedup_zone_bottom_right)
	if in_speedup_zone:
		return

	var touching_left = target_position.x <= position.x + pushbox_top_left.x
	var touching_right = target_position.x >= position.x + pushbox_bottom_right.x
	var touching_top = target_position.z <= position.z + pushbox_top_left.y
	var touching_bottom = target_position.z >= position.z + pushbox_bottom_right.y
	var movement = Vector3()

	if touching_left or touching_right:
		movement.x = velocity.x
	else:
		movement.x = velocity.x * push_ratio

	if touching_top or touching_bottom:
		movement.z = velocity.z
	else:
		movement.z = velocity.z * push_ratio

	position += movement * delta

	super(delta)

func is_in_zone(point: Vector3, top_left: Vector2, bottom_right: Vector2) -> bool:
	return point.x > top_left.x and point.x < bottom_right.x and \
		   point.z > top_left.y and point.z < bottom_right.y

func draw_logic() -> void:
	var mesh_instance := MeshInstance3D.new()
	var immediate_mesh := ImmediateMesh.new()
	var material := ORMMaterial3D.new()

	mesh_instance.mesh = immediate_mesh
	mesh_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = Color.BLACK

	immediate_mesh.surface_begin(Mesh.PRIMITIVE_LINES, material)
	draw_box(immediate_mesh, pushbox_top_left, pushbox_bottom_right)
	immediate_mesh.surface_end()

	immediate_mesh.surface_begin(Mesh.PRIMITIVE_LINES, material)
	draw_box(immediate_mesh, speedup_zone_top_left, speedup_zone_bottom_right)
	immediate_mesh.surface_end()

	add_child(mesh_instance)
	mesh_instance.global_transform = Transform3D.IDENTITY
	mesh_instance.global_position = Vector3(position.x, target.global_position.y, position.z)

	await get_tree().process_frame
	mesh_instance.queue_free()

func draw_box(mesh: ImmediateMesh, top_left: Vector2, bottom_right: Vector2) -> void:
	var left = top_left.x
	var right = bottom_right.x
	var top = top_left.y
	var bottom = bottom_right.y

	mesh.surface_add_vertex(Vector3(right, 0, top))
	mesh.surface_add_vertex(Vector3(right, 0, bottom))

	mesh.surface_add_vertex(Vector3(right, 0, bottom))
	mesh.surface_add_vertex(Vector3(left, 0, bottom))

	mesh.surface_add_vertex(Vector3(left, 0, bottom))
	mesh.surface_add_vertex(Vector3(left, 0, top))

	mesh.surface_add_vertex(Vector3(left, 0, top))
	mesh.surface_add_vertex(Vector3(right, 0, top))
