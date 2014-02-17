extends RigidBody2D

const FORWARD_ACCELERATION = 100
const SIDEWARD_ACCELERATION = 15
const BACKWARD_ACCELERATION = 50
const ROTATIONAL_ACCELERATION = 2

func _ready():
	# Initalization here
	pass

func _integrate_forces(state):

	reset_engines()
	calculate_movement(state)
	calculate_rotation(state)
	calculate_exhaust_trails(state)
	update_camera_zoom()
	
func reset_engines():
	get_node("front_exhaust").set_emitting(false)
	get_node("front_left_exhaust").set_emitting(false)
	get_node("front_right_exhaust").set_emitting(false)
	get_node("back_left_exhaust").set_emitting(false)
	get_node("back_right_exhaust").set_emitting(false)
	get_node("rear_exhaust_1").set_emitting(false)
	get_node("rear_exhaust_2").set_emitting(false)


func calculate_movement(state):
	var lv = state.get_linear_velocity()
	var av = state.get_angular_velocity()
	var step = state.get_step()
	var thrust_vector = Vector2(0,0)
	
	var ship_forward      = Input.is_action_pressed("ship_forward")
	var ship_backward     = Input.is_action_pressed("ship_backward")
	var ship_strafe_left  = Input.is_action_pressed("ship_strafe_left")
	var ship_strafe_right = Input.is_action_pressed("ship_strafe_right")

	if(ship_forward):
		thrust_vector.x = sin(self.get_rot())
		thrust_vector.y = cos(self.get_rot())
		lv.y -= (FORWARD_ACCELERATION * thrust_vector.y * step)
		lv.x -= (FORWARD_ACCELERATION * thrust_vector.x * step)
		get_node("rear_exhaust_1").set_emitting(true)
		get_node("rear_exhaust_2").set_emitting(true)
	if(ship_backward):
		thrust_vector.x = sin(self.get_rot())
		thrust_vector.y = cos(self.get_rot())
		lv.y += (BACKWARD_ACCELERATION * thrust_vector.y * step)
		lv.x += (BACKWARD_ACCELERATION * thrust_vector.x * step)
		get_node("front_exhaust").set_emitting(true)
	if(ship_strafe_left):
		thrust_vector.x = sin(self.get_rot() + deg2rad(90))
		thrust_vector.y = cos(self.get_rot() + deg2rad(90))
		lv.y -= (SIDEWARD_ACCELERATION * thrust_vector.y * step)
		lv.x -= (SIDEWARD_ACCELERATION * thrust_vector.x * step)
		get_node("front_right_exhaust").set_emitting(true)
		get_node("back_right_exhaust").set_emitting(true)
	if(ship_strafe_right):
		thrust_vector.x = sin(self.get_rot() - deg2rad(90))
		thrust_vector.y = cos(self.get_rot() - deg2rad(90))
		lv.y -= (SIDEWARD_ACCELERATION * thrust_vector.y * step)
		lv.x -= (SIDEWARD_ACCELERATION * thrust_vector.x * step)
		get_node("front_left_exhaust").set_emitting(true)
		get_node("back_left_exhaust").set_emitting(true)
	state.set_linear_velocity(lv)
	
func calculate_rotation(state):
	var av = state.get_angular_velocity()
	var step = state.get_step()
	var ship_rotate_left  = Input.is_action_pressed("ship_rotate_left")
	var ship_rotate_right = Input.is_action_pressed("ship_rotate_right")
	
	if (ship_rotate_left and ship_rotate_right):
		pass
	elif(ship_rotate_left):
		av -= (ROTATIONAL_ACCELERATION * step)
		get_node("front_right_exhaust").set_emitting(true)
		get_node("back_left_exhaust").set_emitting(true)
	elif(ship_rotate_right):
		av += (ROTATIONAL_ACCELERATION * step)
		get_node("front_left_exhaust").set_emitting(true)
		get_node("back_right_exhaust").set_emitting(true)
	else:
		if(av > -0.07 and av < 0.07): # If we have an appreciable
			pass
		elif(av > 0.07): # Turn left
			av -= (ROTATIONAL_ACCELERATION * step)
			get_node("front_right_exhaust").set_emitting(true)
			get_node("back_left_exhaust").set_emitting(true)
		else: # Turn right
			av += (ROTATIONAL_ACCELERATION * step)
			get_node("front_left_exhaust").set_emitting(true)
			get_node("back_right_exhaust").set_emitting(true)

	state.set_angular_velocity(av)
	
func calculate_exhaust_trails(state):

	var lv = state.get_linear_velocity()
	var direction_angle = rad2deg(Vector2(0,0).angle_to(lv))
	var facing_angle = rad2deg(self.get_rot())
	var exhaust_trail = direction_angle - facing_angle
	var force_acting_on_exhaust = lv.length() * 10
	
	get_node("front_exhaust").set_param(5, exhaust_trail)
	get_node("front_left_exhaust").set_param(5, exhaust_trail)
	get_node("front_right_exhaust").set_param(5, exhaust_trail)
	get_node("back_left_exhaust").set_param(5, exhaust_trail)
	get_node("back_right_exhaust").set_param(5, exhaust_trail)
	get_node("rear_exhaust_1").set_param(5, exhaust_trail)
	get_node("rear_exhaust_2").set_param(5, exhaust_trail)
	
	get_node("front_exhaust").set_param(6, force_acting_on_exhaust)
	get_node("front_left_exhaust").set_param(6, force_acting_on_exhaust)
	get_node("front_right_exhaust").set_param(6, force_acting_on_exhaust)
	get_node("back_left_exhaust").set_param(6, force_acting_on_exhaust)
	get_node("back_right_exhaust").set_param(6, force_acting_on_exhaust)
	get_node("rear_exhaust_1").set_param(6, force_acting_on_exhaust)
	get_node("rear_exhaust_2").set_param(6, force_acting_on_exhaust)


func update_camera_zoom():
	var zoom_out = Input.is_action_pressed("camera_zoom_out")
	var zoom_in  = Input.is_action_pressed("camera_zoom_in")
	var zoom     = get_node("camera").get_zoom()
	
	if(zoom_out or zoom_in):
		if(zoom_out):
			zoom.x += 0.1
			zoom.y += 0.1
		elif(zoom_in and zoom.x > 1):
			zoom.x -= 0.1
			zoom.y -= 0.1
		get_node("camera").set_zoom(zoom)
