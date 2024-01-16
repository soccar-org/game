extends VehicleBody3D

const MAX_STEER_ANGLE = 45
const ENGINE_POWER = 1000

const BOOST_SPEED = 800.0
const JUMP_VELOCITY = 20.0
var is_boosting = false  # A flag to indicate if the vehicle is currently boosting

var front_left_wheel
var front_right_wheel
var rear_left_wheel
var rear_right_wheel
var ground_ray

func _ready():
	# $FrontWheelRight
	front_left_wheel = $FrontLeftWheel
	front_right_wheel = $FrontRightWheel
	rear_left_wheel = $RearLeftWheel
	rear_right_wheel = $RearRightWheel 
	

	ground_ray = $RayCast3D
	ground_ray.enabled = true

func _physics_process(delta):
	handle_steering(delta)
	handle_movement(delta)
	
	check_for_boost()
	handle_jump()
	
	# if Input.is_action_just_pressed("jump"): print("Jump button pressed")
	if ground_ray.is_colliding(): print("Grounded")
	else: print("Not Grounded")


func handle_steering(delta):
	var steer_input = Input.get_axis("left", "right")
	front_left_wheel.steering = -steer_input * MAX_STEER_ANGLE
	front_right_wheel.steering = -steer_input * MAX_STEER_ANGLE

func handle_movement(delta):
	var gas_input = Input.get_action_strength("gas")
	var brake_input = Input.get_action_strength("reverse")

	var engine_force = 0.0

	if gas_input > 0:
		# Positive engine force for forward movement
		engine_force = gas_input * ENGINE_POWER
		print("GAS")
	elif brake_input > 0:
		# Negative engine force for braking or reversing
		engine_force = -brake_input * ENGINE_POWER
		
	# Apply the engine force to the front wheels
	front_left_wheel.engine_force = engine_force
	front_right_wheel.engine_force = engine_force
	rear_left_wheel.engine_force = engine_force
	rear_right_wheel.engine_force = engine_force

func check_for_boost():
	is_boosting = Input.is_action_pressed("boost")

func handle_jump():
	ground_ray.force_raycast_update()
	
	if Input.is_action_just_pressed("jump") and ground_ray.is_colliding():
		apply_impulse(Vector3(0, JUMP_VELOCITY, 0), Vector3.ZERO)
