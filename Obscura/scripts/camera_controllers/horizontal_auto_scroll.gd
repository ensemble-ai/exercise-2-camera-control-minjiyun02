class_name HorizontalAutoScroll
extends CameraControllerBase

@export var top_left: Vector2
@export var bottom_right: Vector2
@export var autoscroll_speed: Vector3

var top_left_process: Vector2
var bottom_right_process: Vector2

func _ready() -> void:
	super()
	position = target.position
	top_left_process = top_left
	bottom_right_process = bottom_right

func _process(delta: float) -> void:
	if !current:
		return
		
	if draw_camera_logic:
		draw_logic()
	
	var scroll_offset = autoscroll_speed * delta
	top_left_process += Vector2(scroll_offset.x, scroll_offset.y)
	bottom_right_process += Vector2(scroll_offset.x, scroll_offset.y)
	
	global_position.x = (top_left_process.x + bottom_right_process.x) / 2
	global_position.z = (top_left_process.y + bottom_right_process.y) / 2
	global_position.y = target.global_position.y
	
	var player_left_edge = target.global_position.x - target.WIDTH / 2.0
	var frame_left_edge = top_left_process.x
	if player_left_edge < frame_left_edge:
		target.global_position.x += frame_left_edge - player_left_edge
	
	var player_bottom_edge = target.global_position.z + target.HEIGHT / 2.0
	var frame_bottom_edge = bottom_right_process.y
	if player_bottom_edge > frame_bottom_edge:
		target.global_position.z += frame_bottom_edge - player_bottom_edge
		
	var player_top_edge = target.global_position.z - target.HEIGHT / 2.0
	var frame_top_edge = top_left_process.y
	if player_top_edge < frame_top_edge:
		target.global_position.z += frame_top_edge - player_top_edge
		
	var player_right_edge = target.global_position.x + target.WIDTH / 2.0
	var frame_right_edge = bottom_right_process.x
	if player_right_edge > frame_right_edge:
		target.global_position.x += frame_right_edge - player_right_edge
	
	super(delta)
	
func draw_logic() -> void:
	var mesh_instance := MeshInstance3D.new()
	var immediate_mesh := ImmediateMesh.new()
	var material := ORMMaterial3D.new()
	
	mesh_instance.mesh = immediate_mesh
	mesh_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	
	immediate_mesh.surface_begin(Mesh.PRIMITIVE_LINES, material)
	
	var top_left_3d = Vector3(top_left.x, 0, top_left.y)
	var top_right_3d = Vector3(bottom_right.x, 0, top_left.y)
	var bottom_left_3d = Vector3(top_left.x, 0, bottom_right.y)
	var bottom_right_3d = Vector3(bottom_right.x, 0, bottom_right.y)
	
	immediate_mesh.surface_add_vertex(top_left_3d)
	immediate_mesh.surface_add_vertex(top_right_3d)
	
	immediate_mesh.surface_add_vertex(top_right_3d)
	immediate_mesh.surface_add_vertex(bottom_right_3d)
	
	immediate_mesh.surface_add_vertex(bottom_right_3d)
	immediate_mesh.surface_add_vertex(bottom_left_3d)
	
	immediate_mesh.surface_add_vertex(bottom_left_3d)
	immediate_mesh.surface_add_vertex(top_left_3d)
	
	immediate_mesh.surface_end()
	
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = Color.BLACK
	
	add_child(mesh_instance)
	mesh_instance.global_transform = Transform3D.IDENTITY
	mesh_instance.global_position = Vector3(global_position.x, target.global_position.y, global_position.z)
	
	await get_tree().process_frame
	mesh_instance.queue_free()
