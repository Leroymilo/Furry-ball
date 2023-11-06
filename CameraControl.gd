extends Node3D

const MINDIST = 2
const MAXDIST = 5
var dist = 5

func _ready():
	$CameraNode/Camera3D.position = Vector3(0, 0, dist)

func _input(event):
	
	if event.is_action("zoom_in"):
		dist -= 0.1
	
	if event.is_action("zoom_out"):
		dist += 0.1
	
	dist = clamp(dist, MINDIST, MAXDIST)
	$CameraNode/Camera3D.position = Vector3(0, 0, dist)
