extends StaticBody3D

var shader = preload("res://sphere.gdshader")

const SHELL_NB = 64
var shells: Array[MeshInstance3D] = []

const SENS = 0.01
var rotating = false
var moving = false

var rot_del = 0
var rot_intensity = 0

var disp = Vector3.ZERO
var inst_disp = Vector3.ZERO

# Called when the node enters the scene tree for the first time.
func _ready():
	for i in range(SHELL_NB):
		var shell = MeshInstance3D.new()
		shell.name = "shell" + str(i)
		shell.sorting_offset = i
		
		var mesh = SphereMesh.new()
		mesh.radius = 1
		mesh.height = 2
		shell.mesh = mesh
		
		var material = ShaderMaterial.new()
		material.shader = shader
		material.set_shader_parameter("H", float(i)/SHELL_NB)
		shell.set_surface_override_material(0, material)
		
		shells.append(shell)
		self.add_child(shell)

func add_displacement(disp: Vector3):
	inst_disp += to_local(disp + transform.origin)

func _physics_process(delta):
	disp = disp * exp(-delta) + inst_disp
	inst_disp = Vector3.ZERO
	
	rotate_y(rot_del * SENS)
	rot_intensity = rot_intensity * exp(-delta) + 0.0001 * rot_del / delta
	rot_del = 0
	
	update_shader(delta)

func _input(event):
	if event.is_action("rotate"):
		rotating = event.pressed
		
	if event is InputEventMouseMotion and rotating:
		rot_del += event.relative.x / 2
	
	if event.is_action("move"):
		moving = event.pressed

	if event is InputEventMouseMotion and moving:
		var cur_pos = Vector3(position)
		var v2 = event.relative * 0.005
		var v3 = Vector3(v2.x, -v2.y, 0)
		self.global_translate(v3)
		# TODO : clamp pos
		add_displacement(cur_pos - position)
	
	if event.is_action_pressed("reset"):
		position = Vector3.ZERO
		rotation = Vector3.ZERO

func update_shader(delta):
	var full_disp = (disp - Vector3.UP).normalized()
	#gravity
	
	for shell in shells:
		var material: ShaderMaterial = shell.get_surface_override_material(0)
		material.set_shader_parameter("displacement", full_disp)
		material.set_shader_parameter("rot_intensity", rot_intensity)
