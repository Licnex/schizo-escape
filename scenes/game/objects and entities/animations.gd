extends AnimatedSprite2D

@export var controller : PlayerController
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	play("running")
	controller.connect("threw", throw)
	pass # Replace with function body.
var is_throwing := false
func _process(delta: float) -> void:
	if is_throwing:
		return
	
	play_the_right_animation()

func play_the_right_animation():

	if controller.direction == -1:
		flip_h = true
	if controller.direction == 1:
		flip_h = false

	if controller._is_wall_sliding:
		play("wall_slide")
		if controller.direction == -1:
			flip_h = false
		if controller.direction == 1:
			flip_h = true

	elif controller.is_on_floor() and controller.velocity.x == 0:
		play("idle")

	elif controller.is_on_floor() and abs(controller.velocity.x) > 0:
		play("running")

	elif !controller.is_on_floor():
		play("jumping")
func throw():
	is_throwing = true
	play("throw")
	await animation_finished
	is_throwing = false
