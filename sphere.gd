extends StaticBody3D

# Preloads
var shader = preload("res://sphere.gdshader")
var mesh: SphereMesh

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

func add_shell():
	var i = shells.size()
	var shell = MeshInstance3D.new()
	shell.name = "shell" + str(i)
	shell.sorting_offset = i
	shell.mesh = mesh
	
	var material = ShaderMaterial.new()
	material.shader = shader
	shell.set_surface_override_material(0, material)
	
	shells.append(shell)
	self.add_child(shell)
	SHELL_NB += 1

func remove_shell():
	shells.pop_back().queue_free()
	SHELL_NB -= 1

func update_shell_H():
	for i in range(SHELL_NB):
		var material: ShaderMaterial = shells[i].get_surface_override_material(0)
		material.set_shader_parameter("H", float(i) / SHELL_NB)
	return

# Setups the shells for the first time, to call after setting parameters
func _ready():
	mesh = SphereMesh.new()
	mesh.radius = 1
	mesh.height = 2
	
	prev_transf = Transform3D(transform)

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
	
	for shell in shells:
		var material: ShaderMaterial = shell.get_surface_override_material(0)
		material.set_shader_parameter("L", L)
		material.set_shader_parameter("DENSITY", DENSITY)
		material.set_shader_parameter("base_color", base_color)
		material.set_shader_parameter("del_transf", final_transf)


func _on_stiffness_changed(value):
	STIFF = value

func _on_shell_nb_changed(value):
	if value == SHELL_NB: return
	
	while len(shells) < value:
		add_shell()
	
	while len(shells) > value:
		remove_shell()
	
	update_shell_H()

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
