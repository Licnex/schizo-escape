class_name PlayerController
extends CharacterBody2D

## Emitted on the frame a jump starts.
signal jumped ## Rn just there for future reference incase someone cooks
## Emitted on the frame the character touches the floor after being airborne.
signal landed ## Rn just there for future reference incase someone cooks
signal threw


@export_group("Run")
## Top horizontal speed, in pixels per second.
@export var max_speed: float = 320.0
## Ground acceleration, in pixels per second squared.
@export var ground_acceleration: float = 2800.0
## Ground braking, used when there is no input or when reversing direction.
@export var ground_deceleration: float = 3400.0
## Air acceleration. Lower than ground keeps mid-air control deliberate.
@export var air_acceleration: float = 1900.0
## Air braking, used when no direction is held.
@export var air_deceleration: float = 1300.0

@export_group("Jump")
## Jump height at full press, in pixels.
@export var jump_height: float = 140.0
## Seconds from takeoff to the top of the jump arc.
@export var jump_time_to_peak: float = 0.35
## Seconds from the top of the arc back down to takeoff height.
## Shorter than the rise reads as weight; equal reads as floaty.
@export var jump_time_to_fall: float = 0.28
## Grace window to jump after walking off a ledge, in seconds.
@export var coyote_time: float = 0.10
## How early a jump press is remembered before landing, in seconds.
@export var jump_buffer_time: float = 0.12
## Multiplier applied to upward speed when jump is released mid-rise.
## Lower values cut the jump shorter.
@export_range(0.0, 1.0, 0.05) var jump_cut_factor: float = 0.4
## Terminal fall speed, in pixels per second.
@export var max_fall_speed: float = 900.0
## The Speed at which you slide on walls.
@export var wallslide_speed: float = 100.0
## The factor for the speed at which you jump away from a wall
@export var kick_factor: float = 1.0

@export_group("throwable")
#the scene that contains the throwable object
@export var throwable_scene: PackedScene
#the speed the throwable will be thrown at
@export var throwable_speed: float = 600
#the multiplyer for the thrown objects gravity, used for player scaling.
@export var throwable_gravity_mult:float = 1

@onready var sprite_2d: Sprite2D = $Sprite2d
@onready var camera_2d: Camera2D = $Camera2D
@onready var throw_marker: Marker2D = $throw_marker



var _coyote_left: float = 0.0
var _buffer_left: float = 0.0
var _was_on_floor: bool = false
var _is_wall_sliding: bool = false
var direction : float = 0

## Replaces the current velocity, e.g. with a damage knockback impulse.
## Kept generic on purpose: the controller knows nothing about damage.
func apply_knockback(knockback: Vector2) -> void:
	velocity = knockback


func _ready() -> void:
	## Scaling everything to the size of the player
	var s = scale.x *0.5
	max_speed *= s
	ground_acceleration *= s
	air_acceleration *= s
	ground_deceleration *= s
	air_deceleration *= s
	jump_height *= s
	max_fall_speed *= s
	camera_2d.zoom *= 1.0/s
	throwable_speed *= s
	throwable_gravity_mult *= s


func _physics_process(delta: float) -> void:
	direction = Input.get_axis("move_left", "move_right")
	if direction == -1:
		sprite_2d.flip_h = true
	elif direction == 1:
		sprite_2d.flip_h = false
	_apply_gravity(delta)
	_update_wallslide(delta)
	_run(direction, delta)
	_update_jump(delta)
	move_and_slide()
	_update_floor_state()

func _apply_gravity(delta: float) -> void:
	var gravity: float = _fall_gravity() if velocity.y > 0.0 else _rise_gravity()
	velocity.y = minf(velocity.y + gravity * delta, max_fall_speed)


func _run(direction: float, delta: float) -> void:
	var braking: bool = is_zero_approx(direction) or direction * velocity.x < 0.0
	var rate: float
	if is_on_floor():
		rate = ground_deceleration if braking else ground_acceleration
	else:
		rate = air_deceleration if braking else air_acceleration
	velocity.x = move_toward(velocity.x, direction * max_speed, rate * delta)
	if _is_wall_sliding:
		velocity.y = min(velocity.y, wallslide_speed)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("throw"):
		throw_object()
		

func _update_wallslide(delta: float) -> void:
	if not is_on_floor() and is_on_wall():
		_is_wall_sliding = true
	else:
		_is_wall_sliding = false


func _update_jump(delta: float) -> void:
	## Wall Slide stuff
	if (_is_wall_sliding and Input.is_action_just_pressed("jump")):
		velocity.y = -_jump_velocity()
		velocity.x = get_wall_normal().x * max_fall_speed * kick_factor
		_buffer_left = 0.0
		_coyote_left = 0.0
		jumped.emit()
		return
	## Regular jump code
	_coyote_left = maxf(_coyote_left - delta, 0.0)
	_buffer_left = maxf(_buffer_left - delta, 0.0)
	if Input.is_action_just_pressed("jump"):
		_buffer_left = jump_buffer_time
	if _buffer_left > 0.0 and (is_on_floor() or _coyote_left > 0.0):
		_buffer_left = 0.0
		_coyote_left = 0.0
		velocity.y = -_jump_velocity()
		jumped.emit()
	if Input.is_action_just_released("jump") and velocity.y < 0.0:
		velocity.y *= jump_cut_factor


func _update_floor_state() -> void:
	var on_floor: bool = is_on_floor()
	if on_floor and not _was_on_floor:
		landed.emit()
	# The coyote window opens only when the floor is lost by walking off a
	# ledge (falling). A jump sets negative velocity, so it never re-arms it.
	if _was_on_floor and not on_floor and velocity.y >= 0.0:
		_coyote_left = coyote_time
	_was_on_floor = on_floor


# Plain projectile kinematics: v = 2h/t, g = 2h/t^2.
func _jump_velocity() -> float:
	return 2.0 * jump_height / jump_time_to_peak


func _rise_gravity() -> float:
	return 2.0 * jump_height / (jump_time_to_peak * jump_time_to_peak)


func _fall_gravity() -> float:
	return 2.0 * jump_height / (jump_time_to_fall * jump_time_to_fall)


func throw_object():
	if throwable_scene == null:
		return
	emit_signal("threw")
	var thrown_object = throwable_scene.instantiate()
	var throw_vector = global_position.direction_to(get_global_mouse_position())
	var base_throw_velocity = throw_vector * throwable_speed
	thrown_object.linear_velocity = base_throw_velocity #used to add player velocity (removed for predictability)
	thrown_object.gravity_scale = thrown_object.gravity_scale * throwable_gravity_mult
	thrown_object.global_position = throw_marker.global_position
	get_tree().current_scene.add_child(thrown_object)


func _die():
	velocity = Vector2(0,0)
	global_position = Autoload1.last_checkpoint
