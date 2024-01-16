extends Node3D  # Attach this script to the TwistPivot node

@export var mouse_sensitivity = 0.05
@export var invert_x = true  # Toggle to invert camera rotation on the X-axis
@export var invert_y = true  # Toggle to invert camera rotation on the Y-axis

var camera_yaw = 0.0  # Store yaw in radians
var camera_pitch = 0.0  # Store pitch in radians

# ------------------


@onready var target = $"../../Ball"
var ballcam = true

func _ready():
	# Assuming 'rotation_degrees' is the initial rotation of this node
	camera_yaw = deg_to_rad(rotation_degrees.y)
	# Assuming $PitchPivot.rotation_degrees.x is the initial pitch rotation
	camera_pitch = deg_to_rad($PitchPivot.rotation_degrees.x)

	if target:
		print("Target node (Ball) found!")
	else:
		print("Target node (Ball) not found.")

func _input(event):
	pan_camera(event)
	toggle_camera_mode(event)

func pan_camera(event):
	if event is InputEventMouseMotion:
		var mouse_delta_x = event.relative.x * mouse_sensitivity
		var mouse_delta_y = event.relative.y * mouse_sensitivity

		if invert_x:
			mouse_delta_x = -mouse_delta_x
		if invert_y:
			mouse_delta_y = -mouse_delta_y

		# Rotate the pivot nodes based on mouse movement
		camera_yaw += deg_to_rad(mouse_delta_x)
		camera_pitch += deg_to_rad(mouse_delta_y)

		# Clamp the pitch rotation
		camera_pitch = clamp(camera_pitch, deg_to_rad(-90), deg_to_rad(90))

		# Apply the rotations to the pivot nodes
		rotation_degrees.y = rad_to_deg(camera_yaw)
		$PitchPivot.rotation_degrees.x = rad_to_deg(camera_pitch)

func toggle_camera_mode(event):
	if event.is_action_pressed("ballcam"):
		ballcam = !ballcam
		
func _process(delta):
	if ballcam and target:
		# Continuously look at the target while in ballcam mode
		look_at(target.global_transform.origin, Vector3.UP)
