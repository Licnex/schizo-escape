extends CharacterBody2D


const SPEED = 100.0 # the players ground speed
const AIR_CONTROL_SPEED = 40 #the players speed while in the air.
const JUMP_VELOCITY = -400.0 #jump speed.
const MAX_SPEED = 400 #speed cap.
const WALL_SLIDE_SPEED = 2 #the speed at which the player will fall during a wall jump (only works if velocity.y > 0).
const WALL_SLIDE_AMOUNT = 600 #amount of wallslides available before touching the ground.
const WALL_JUMP_VERTICAL_SPEED = 200 #the speed the player will be pushed off the wall with when doing a wall jump.

var is_wall_sliding = false #tracks whether the player character is wall sliding.
var wall_slide_counter = WALL_SLIDE_AMOUNT #counter used to determine how many wallslides done before hitting the ground last.
var do_gravity : bool #a boolean that determines whether gravity is active for the player.
var is_in_fan = false #checks if the player is in the fan hitbox.



func _physics_process(delta: float) -> void:
	
	#do gravity function
	if do_gravity == true:
		velocity += get_gravity() * delta
	# Add the gravity.
	if not is_on_floor() and is_wall_sliding == false:
		do_gravity = true
	else:
		do_gravity = false
	
	# Handle on floor jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		
	# Get the input direction and handle the movement/deceleration.
	# Vertical movement for if the player is on the ground directly
	var direction := Input.get_axis("move_left", "move_right")
	if direction and is_on_floor():
		velocity.x = (direction * SPEED) + velocity.x
		velocity.x = clamp(velocity.x,MAX_SPEED * -1,MAX_SPEED)
	elif is_on_floor():
		velocity.x = move_toward(velocity.x, 0, SPEED*2)
		
	#vertical movement for if the player is in the air
	if direction and is_on_floor() == false:
		velocity.x = (direction * AIR_CONTROL_SPEED) + velocity.x
		velocity.x = clamp(velocity.x,MAX_SPEED * -1,MAX_SPEED)
	elif is_on_floor() == false :
		velocity.x = move_toward(velocity.x, 0, 5)



		#wallslide logic to check for wallsliding
	if is_on_floor() == false and is_on_wall() and velocity.y <800 and wall_slide_counter > 0 and (get_wall_normal().x *-1) * direction > 0:
		if is_wall_sliding == false:
				is_wall_sliding = true

#what it does if it is wall sliding
	if is_wall_sliding == true:
		if velocity.y <= 0:
			do_gravity = true
			velocity.y = velocity.y + 10
		else:
			do_gravity = false
		velocity.y = (velocity.y + WALL_SLIDE_SPEED)

#wall slide jumping
	if Input.is_action_just_pressed("jump") and is_wall_sliding:
		var jump_direction = get_wall_normal()
		velocity.x = jump_direction.x * WALL_JUMP_VERTICAL_SPEED
		velocity.y = JUMP_VELOCITY

#making the code stop a wallslide
	if is_wall_sliding and is_on_wall() == false or Input.is_action_just_pressed("jump") and is_wall_sliding == true:
		is_wall_sliding = false
		wall_slide_counter = wall_slide_counter-1

#resetting wall slide counter
	if is_on_floor():
		wall_slide_counter = WALL_SLIDE_AMOUNT




	move_and_slide()
