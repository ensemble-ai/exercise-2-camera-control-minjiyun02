class_name LerpFocusCamera
extends CameraControllerBase

@export var lead_speed: float = 100.0
@export var catchup_delay_duration: float = 1.0
@export var catchup_speed: float = 5.0
@export var leash_distance: float = 10.0

var idle_time: float = 0.0

func _ready() -> void:
	super()
	position = target.position

func _process(delta: float) -> void:
	if !current:
		return

	var target_position = target.global_position
	var distance_to_target = global_position.distance_to(target_position)
	var direction_to_target = (target_position - global_position).normalized()

	var player_moving = target.velocity != Vector3.ZERO

	if player_moving:
		idle_time = 0.0
	else:
		idle_time += delta

	if player_moving:
		var lead_position = target_position + (target.velocity.normalized() * leash_distance)

		if target.velocity.length() > 299.0:
			global_position = global_position.move_toward(lead_position, (lead_speed + 350) * delta)
		else:
			global_position = global_position.move_toward(lead_position, lead_speed * delta)
	elif idle_time >= catchup_delay_duration:
		global_position += direction_to_target * catchup_speed * delta

	if global_position.distance_to(target_position) > leash_distance:
		global_position = target_position - direction_to_target * leash_distance

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
