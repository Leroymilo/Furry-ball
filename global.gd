extends Node3D

const SENS = 0.01
const MINDIST = 2
const MAXDIST = 10
var dist = 5

func _ready():
	$CameraNode/Camera3D.position = Vector3(0, 0, dist)
	reset()

func reset():
		$Sphere.position = Vector3.ZERO
		$Sphere.rotation = Vector3.ZERO
		
		$HUD/ShellNbSlider.set_value(64)
		$Sphere._on_shell_nb_changed(64)
		$HUD/StiffnessSlider.set_value(0)
		$Sphere._on_stiffness_changed(0)
		$HUD/TimeSlider.set_value(10)
		$Sphere._on_time_changed(10)
		$HUD/DensitySlider.set_value(512)
		$Sphere._on_density_changed(512)
		$HUD/LengthSlider.set_value(0.2)
		$Sphere._on_length_changed(0.2)
		$HUD/ColorPickerButton.color = Color("#f2c98a")
		$Sphere._on_color_changed(Color("#f2c98a"))

func _input(event):
	
	if event.is_action("zoom_in"):
		dist -= 0.1
	
	if event.is_action("zoom_out"):
		dist += 0.1
	
	if event.is_action_pressed("reset"):
		reset()
	
	dist = clamp(dist, MINDIST, MAXDIST)
	$CameraNode/Camera3D.position = Vector3(0, 0, dist)

func _process(delta):
	var text = "fps : " + str(snapped(1/delta, 0.001))
	text += "\nshells : " + str($HUD/ShellNbSlider.value)
	text += "\nstrands : " + str(2 * $HUD/DensitySlider.value ** 2)
	
	$HUD/Info.text = text
