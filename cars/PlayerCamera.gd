extends Node3D  # Attach this script to the TwistPivot node

@export var mouse_sensitivity = 0.1
@export var invert_x = true  # Toggle to invert camera rotation on the X-axis
@export var invert_y = true  # Toggle to invert camera rotation on the Y-axis

 
var camera_yaw = 0.0  # Store yaw in radians
var camera_pitch = 0.0  # Store pitch in radians
	
# --------------------
	
# gets reference to target	
@onready var car = $"../redcar" as VehicleBody3D

# gets reference to camera components
@onready var height_pivot = self
@onready var pitch_pivot = $PitchPivot
@onready var distance_pivot = $PitchPivot/Camera3D

@export var chosen_height: float = 1.2
@export var chosen_pitch: float = -2.0  # Assuming degrees, but could also be radians
@export var chosen_distance: float = 2




func _ready():
	if car:
		print("Car node found: ", car.name)
		print("Initial 'is_grounded' value: ", car.is_grounded)
		
		focusandcenter()
		
	else:
		print("Car node not found")
	
func focusandcenter():	
	# Step 1: Match the camera's position and rotation with the car
	height_pivot.global_transform.origin = car.global_transform.origin
	height_pivot.global_transform.basis = car.global_transform.basis
	
	# Hardcode a 180-degree turn on the Y-axis to face the camera the same way as the car
	height_pivot.rotate_y(deg_to_rad(180))

	# Step 2: Apply your height, pitch, and distance
	height_pivot.global_transform.origin.y += chosen_height
	pitch_pivot.rotation_degrees.x = chosen_pitch
	distance_pivot.transform.origin.z += chosen_distance

		
func _process(delta):
	if car:
		print("Current 'is_grounded' value: ", car.is_grounded)
		if car.is_grounded:
			follow_car_on_ground(delta)
		else:
			follow_car_on_ground(delta)
	else:
		print("Car node reference lost")

func follow_car_on_groundold(delta):
	# Align camera's position with the car's position
	height_pivot.global_transform.origin = car.global_transform.origin

	# Align camera's rotation with the car's rotation
	height_pivot.rotation_degrees = car.rotation_degrees

	# Apply the height offset
	height_pivot.global_transform.origin.y += chosen_height

	# Apply the distance offset by moving the camera back along the car's local Z-axis
	# Using Transform3D to create a transformation matrix with the desired offset
	var rotation_offset = Transform3D(Basis(), Vector3(0, 0, -chosen_distance))
	height_pivot.global_transform = height_pivot.global_transform * rotation_offset

func follow_car_on_ground(delta):
	# Align the camera's global transform with the car's, then apply the distance offset
	height_pivot.global_transform = car.global_transform
	height_pivot.global_transform.origin -= height_pivot.global_transform.basis.z.normalized() * chosen_distance

	# Apply the height offset
	height_pivot.global_transform.origin.y = car.global_transform.origin.y + chosen_height

	# Rotate the camera by 180 degrees around the Y-axis to face forward
	height_pivot.rotate_y(deg_to_rad(180))

	
func follow_car_in_air(delta):
	# Keep the camera's current orientation but interpolate to follow the car's position in the air
	return
# -------------------------------

func _input(event):
	if event is InputEventMouseMotion:
		# handle_look_around(event)
		return
		
func handle_look_around(event):
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
	height_pivot.rotate_y(camera_yaw)
	pitch_pivot.rotation_degrees.x = rad_to_deg(camera_pitch)

	# Reset the yaw value so it does not accumulate beyond necessary rotation
	camera_yaw = 0
	
func recenter_camera():
	camera_yaw = 0.0  
	camera_pitch = 0.0
	# Apply the reset rotation to the pivot nodes
	rotation_degrees.y = rad_to_deg(camera_yaw)
	pitch_pivot.rotation_degrees.x = rad_to_deg(camera_pitch)
