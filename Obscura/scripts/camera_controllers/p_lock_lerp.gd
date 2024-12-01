class_name PositionLockLerpCamera
extends CameraControllerBase

@export var cross_size:float = 5.0
@export var follow_speed:float = 10.0
@export var catchup_speed:float = 6.0
@export var leash_distance:float = 10.0

func _ready() -> void:
	super()
	position = target.position

func _process(delta: float) -> void:
	if !current:
		return
	
	if draw_camera_logic:
		draw_logic()
	var tpos = target.global_position
	var cpos = global_position
	var distance_vector = tpos - cpos
	var distance = distance_vector.length()
	if distance > leash_distance and target.velocity.length() > 0.1:
		global_position = global_position.lerp(tpos, follow_speed * delta / distance)
	elif distance > leash_distance and target.velocity.length() < 0.1:
		global_position = global_position.lerp(tpos, catchup_speed * delta / distance)

	var diff_left = (tpos.x - target.WIDTH / 2.0) - (cpos.x - leash_distance / 2.0)
	if diff_left < 0:
		global_position.x += diff_left

	var diff_right = (tpos.x + target.WIDTH / 2.0) - (cpos.x + leash_distance / 2.0)
	if diff_right > 0:
		global_position.x += diff_right

	var diff_top = (tpos.z - target.HEIGHT / 2.0) - (cpos.z - leash_distance / 2.0)
	if diff_top < 0:
		global_position.z += diff_top

	var diff_bottom = (tpos.z + target.HEIGHT / 2.0) - (cpos.z + leash_distance / 2.0)
	if diff_bottom > 0:
		global_position.z += diff_bottom
	super(delta)

func draw_logic() -> void:
	var mesh_instance := MeshInstance3D.new()
	var immediate_mesh := ImmediateMesh.new()
	var material := ORMMaterial3D.new()
	
	mesh_instance.mesh = immediate_mesh
	mesh_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	
	var half:float = cross_size / 2
	
	immediate_mesh.surface_begin(Mesh.PRIMITIVE_LINES, material)
	immediate_mesh.surface_add_vertex(Vector3(half, 0, 0))
	immediate_mesh.surface_add_vertex(Vector3(-half, 0, 0))
	immediate_mesh.surface_add_vertex(Vector3(0, 0, half))
	immediate_mesh.surface_add_vertex(Vector3(0, 0, -half))
	immediate_mesh.surface_end()

	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = Color.BLACK
	
	add_child(mesh_instance)
	mesh_instance.global_transform = Transform3D.IDENTITY
	mesh_instance.global_position = Vector3(global_position.x, target.global_position.y, global_position.z)
	
	await get_tree().process_frame
	mesh_instance.queue_free()
