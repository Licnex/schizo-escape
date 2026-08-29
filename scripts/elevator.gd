extends Node2D

@export var opened_x: float = 300
@export var closed_x: float = 0
@export var time_to_open_door: float = 0.9

@onready var left_door: Polygon2D = $left_door

func _ready() -> void:
	open_door()

func open_door() -> void:
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_ELASTIC)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(left_door, "texture_offset:x", opened_x, time_to_open_door)

func close_door() -> void:
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_ELASTIC)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(left_door, "texture_offset:x", closed_x, time_to_open_door)
