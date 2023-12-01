extends MultiMeshInstance3D

# Preloads
var shader = preload("res://sphere.gdshader")
var mesh: SphereMesh
var identity: Array[float] = [
	1.0, 0.0, 0.0, 0.0,
	0.0, 1.0, 0.0, 0.0,
	0.0, 0.0, 1.0, 0.0
]
var buffer_array: Array[float] = []

# Parameters
var SHELL_NB: int = 0
var K: float		# movement persistance parameter
var STIFF: float	# strand stiffness
var L: float		# length
var DENSITY: int
var base_color: Color

# Init
var shells: Array[MeshInstance3D] = []

# Controls
var hud_focused = false
var rotating = false
var moving = false

# Physics
var prev_transf = Transform3D()
var del_transf = Transform3D()


func _physics_process(delta):
	del_transf = del_transf.interpolate_with(Transform3D(), 1 - exp(-K*delta))
	del_transf *= transform.inverse() * prev_transf
	
	prev_transf = Transform3D(transform)
	
	update_shader()

func clamp_pos():
	position.x = clamp(position.x, -4, 4)
	position.y = clamp(position.y, -2, 2)

func _input(event):
	if hud_focused: return
	
	if event.is_action("rotate"):
		rotating = event.pressed
		
	if event is InputEventMouseMotion and rotating:
		global_rotate(Vector3.UP, event.relative.x / 200)
		global_rotate(Vector3.RIGHT, event.relative.y / 200)
	
	if event.is_action("move"):
		moving = event.pressed

	if event is InputEventMouseMotion and moving:
		var v2 = event.relative / 200
		var v3 = Vector3(v2.x, -v2.y, 0)
		self.global_translate(v3)
		clamp_pos()

func update_shader():
	# gravity
	var grav = to_local(transform.origin - 0.5 * Vector3.UP)
	
	# stiffness
	var final_transf = del_transf.translated_local(grav)
	final_transf = final_transf.interpolate_with(Transform3D(), STIFF)

	var material: ShaderMaterial = self.get_material_override()
	material.set_shader_parameter("SHELL_NB", SHELL_NB)
	material.set_shader_parameter("L", L)
	material.set_shader_parameter("DENSITY", DENSITY)
	material.set_shader_parameter("base_color", base_color)
	material.set_shader_parameter("del_transf", final_transf)


func _on_stiffness_changed(value):
	STIFF = value

func _on_shell_nb_changed(value):

	multimesh.set_instance_count(value)

	var buffer_array: Array[float] = []
	
	while len(buffer_array) < 12 * value:
		buffer_array += identity
	
	if len(buffer_array) > 12 * value:
		buffer_array = buffer_array.slice(0, 12 * value)
	multimesh.buffer = PackedFloat32Array(buffer_array)
	
#	for i in range(value):
#		multimesh.set_instance_transform(i, Transform3D())

	SHELL_NB = value

func _on_time_changed(value):
	K = value

func _on_color_changed(color):
	base_color = color

func _on_density_changed(value):
	DENSITY = value

func _on_length_changed(value):
	L = value

func enable_camera_controls():
	hud_focused = false

func disable_camera_controls():
	hud_focused = true
