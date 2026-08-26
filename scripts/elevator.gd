extends Node2D

"
1. animations states : door opening door opened door closed 
2. next level script

"

@export var opened_x: float = 300
@export var closed_x: float = 0
@export var time_to_open_door: float = .9

##TODO : if yu find a way to make the second door transparent like the first one -> you are gooated

@onready var left_door = $left_door

func _ready():
	door_opening()

func _unhandled_input(event):
	if Input.is_action_just_pressed("move_left"):
		door_closed()
		print("closing")

	if Input.is_action_just_pressed("move_right"):
		door_opening()
		print("opening")

func door_opening():
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_ELASTIC)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(left_door, "texture_offset:x", opened_x, time_to_open_door)

func door_closed():
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_ELASTIC)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(left_door, "texture_offset:x", closed_x, time_to_open_door)
