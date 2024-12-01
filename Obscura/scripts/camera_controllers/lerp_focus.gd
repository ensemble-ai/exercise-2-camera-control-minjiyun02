class_name LerpFocusCamera
extends CameraControllerBase

@export var cross_size: float = 5.0
@export var lead_speed: float
@export var catchup_delay_duration: float
@export var catchup_speed: float
@export var leash_distance: float

var last_input_direction: Vector3 = Vector3.ZERO
var last_move_time: float = 0.0

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
	var input_direction = get_input_direction()
	var distance_to_player = cpos.distance_to(tpos)
	print("Distance to player: ", distance_to_player)
	if input_direction != Vector3.ZERO:
		last_input_direction = input_direction.normalized()
		last_move_time = Time.get_ticks_msec() / 1000.0
		var target_camera_position = tpos + last_input_direction * leash_distance
		if (Input.is_action_pressed("ui_accept")):
			global_position = tpos + last_input_direction * pow(leash_distance, 0.5)
		else:
			global_position = global_position.lerp(target_camera_position, lead_speed * delta)
		
	else:
		var time_since_last_move = (Time.get_ticks_msec() / 1000.0) - last_move_time
		if time_since_last_move >= catchup_delay_duration:
			global_position = cpos.lerp(tpos, catchup_speed * delta)
	
	super(delta)
	
func get_input_direction() -> Vector3:
	var direction = Vector3.ZERO
	if Input.is_action_pressed("ui_right"):
		direction.x += 1
	if Input.is_action_pressed("ui_left"):
		direction.x -= 1
	if Input.is_action_pressed("ui_down"):
		direction.z += 1
	if Input.is_action_pressed("ui_up"):
		direction.z -= 1
	return direction.normalized()

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
