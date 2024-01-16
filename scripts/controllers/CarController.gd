
extends VehicleBody3D

const ENGINE_POWER = 50000
const MAX_ENGINE_VELOCITY = 40

const STEER_FORCE = 100
const MAX_STEER_VELOCITY = 0.8

const ROLLING_FORCE = 2000
const MAX_ROLLING_VELOCITY = 0.8

const PITCH_FORCE = 0.01

const BOOST_POWER = 30000
const MAX_BOOST_VELOCITY = 20

const JUMP_FORCE = 90

@onready var raycast = $RayCast3D
var is_grounded

# ---------

@onready var front_left_wheel = $FrontLeftWheel/FrontLeftWheel
@onready var front_right_wheel = $FrontRightWheel/FrontRightWheel
@onready var rear_left_wheel = $RearLeftWheel/RearLeftWheel
@onready var rear_right_wheel = $RearRightWheel/RearRightWheel

const MAX_STEER_ANGLE = 45


# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _physics_process(delta):
	is_grounded = raycast.is_colliding()
	
	# check_grounded_status()
	DETERMINE_MOVESET(delta)
	
	handle_boosting(delta)
	
	if is_flipping:
		maintain_flip_axis()
	
func check_grounded_status():
	print("Is Grounded: ", is_grounded)
	if is_grounded:
		print("Colliding with: ", $RayCast3D.get_collider())

# -------------------------------
func DETERMINE_MOVESET(delta):
	if is_grounded:
		#print("-----------------GROUND-------------------")
		ground_moveset(delta)

		handle_jumping(delta)
		is_flipping = false
	else:
		#print("-----------------AIR-------------------")
		if not is_flipping:
			air_moveset(delta)
			handle_jumping(delta)
		#handle_flipping(delta)

# -------------------------------	


# ----------------------------------------
# ---------- GROUND MOVESET --------------
# ----------------------------------------
func ground_moveset(delta):
	
	handle_accelerating(delta)
	handle_steering(delta)

# ----
func handle_jumping(delta):
	if Input.is_action_just_pressed("jump"):
		# velocity.y = 20
		apply_central_impulse(Vector3(0, JUMP_FORCE, 0))

# ----
func handle_accelerating(delta):
	var direction = global_transform.basis.z.normalized()
	var input = Input.get_axis("reverse", "gas") 
	var force = direction * input * ENGINE_POWER
	
	# Limit maximum engine velocity
	var current_velocity = linear_velocity.dot(direction)
	if current_velocity < MAX_ENGINE_VELOCITY:
		apply_central_force(force * delta)

# ----
func handle_steering(delta):
	var turn_input = Input.get_axis("right", "left")
	var torque = Vector3(0, STEER_FORCE * turn_input, 0)

	# Limit maximum steer velocity
	var current_steer_velocity = angular_velocity.y
	if abs(current_steer_velocity) < MAX_STEER_VELOCITY:
		apply_torque(torque * delta)


func handle_steeringcorrectway(delta):
	var steer_input = Input.get_axis("left", "right")
	front_left_wheel.steering = -steer_input * MAX_STEER_ANGLE
	front_right_wheel.steering = -steer_input * MAX_STEER_ANGLE
	print("STEER INPUT: ", steer_input)

# ----------------------------------------
# ------------- AIR MOVESET --------------
# ----------------------------------------

var is_flipping = false

func air_moveset(delta):
	
	handle_pitch(delta)
	handle_yaw(delta)
	handle_roll(delta)
	
	
func handle_flipping(delta):
	# TODO limit to 1 flip, and add timer
	if Input.is_action_just_pressed("jump"):
		
		var dir = get_direction()
		print("- ")	
		print("- ")			
		print("- ")	
		print("RAW DIR ================== ", dir)	
			
		# if jump not neutral
		if dir.length() > 0:
			#make_flip(dir, delta)
			apply_central_impulse(Vector3(0, JUMP_FORCE, 0))
		else:
			apply_central_impulse(Vector3(0, JUMP_FORCE, 0))

# ----

func get_direction() -> Vector2:
	var x = Input.get_action_strength("forward") - Input.get_action_strength("backward")
	var y = Input.get_action_strength("right") - Input.get_action_strength("left")
	return Vector2(x, y).normalized()


const INITIAL_FLIP_TORQUE = 120
var torque_direction
# ---- FLIPPING HERE ------------

func make_flip(dir, delta):
	
	print("direction of flip ", dir)
	is_flipping = true
	torque_direction = Vector3(dir.x, dir.y, 0)
	
	execute_flip()

# ----	
func execute_flip():
	
	apply_impulse(torque_direction * INITIAL_FLIP_TORQUE)
	print("torque direction ", torque_direction)
	print("flip force ", INITIAL_FLIP_TORQUE)
	print("Applying torque: ", torque_direction * INITIAL_FLIP_TORQUE)


# ----
func maintain_flip_axis():
	var ang_vel = angular_velocity
	ang_vel = torque_direction * ang_vel.dot(torque_direction)  # Preserve rotation only around flip axis
	angular_velocity = ang_vel
	
	
# ---- ------

func handle_pitch(delta):
	var input = Input.get_axis("backward", "forward")
	var pitch_speed = 1.5
	var pitch_amount = input * pitch_speed * delta

	# Create a quaternion representing the rotation around the local X-axis
	var rotation_quat = Quaternion(global_transform.basis.x.normalized(), pitch_amount)

	# Apply the rotation to the global transform
	global_transform.basis = global_transform.basis.rotated(global_transform.basis.x.normalized(), pitch_amount)


# ----

func handle_yaw(delta):
	var input = Input.get_axis("right", "left")
	var yaw_speed = 1.5
	var yaw_amount = input * yaw_speed * delta

	# Create a quaternion representing the rotation around the local Y-axis
	var rotation_quat = Quaternion(global_transform.basis.y.normalized(), yaw_amount)

	# Apply the rotation to the global transform
	global_transform.basis = global_transform.basis.rotated(global_transform.basis.y.normalized(), yaw_amount)


# ----

func handle_roll(delta):
	var input = Input.get_axis("left-roll", "right-roll")
	var roll_speed = 1.5
	var roll_amount = input * roll_speed * delta

	# Create a quaternion representing the rotation
	var rotation_quat = Quaternion(global_transform.basis.z.normalized(), roll_amount)

	# Convert quaternion to basis and apply the rotation
	global_transform.basis = global_transform.basis.rotated(global_transform.basis.z.normalized(), roll_amount)


# ----------------

# ----------------------------------------


# -------------- JUMPING --------------

func handle_boosting1():
	if Input.is_action_pressed("boost"):
		var local_impulse_direction = Vector3(0, 0, -1)  # Local direction at the rear of the vehicle
		var global_impulse = global_transform * local_impulse_direction  # Transform to global direction
		global_impulse = global_impulse.normalized() * BOOST_POWER
		apply_central_impulse(global_impulse)
		# Add effects or sound here

func handle_boosting(delta):
	if Input.is_action_pressed("boost"):
		print("Boost button pressed")
		
		var boost_direction = global_transform.basis.z.normalized()
		var current_velocity_in_boost_direction = global_transform.basis.z.dot(linear_velocity)
		
		if current_velocity_in_boost_direction < MAX_BOOST_VELOCITY:
			apply_central_force(boost_direction * BOOST_POWER * delta)
