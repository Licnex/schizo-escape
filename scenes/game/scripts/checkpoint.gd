@tool
extends Area2D



@onready var collision: CollisionShape2D = $CollisionShape2D

@export var collision_size: Vector2 = Vector2(200,200):
	set(value):
		collision_size = value
		if is_node_ready and collision and collision.shape:
			collision.shape = collision.shape.duplicate()
			collision.shape.size = collision_size









func _on_body_entered(body: Node2D) -> void:
	if body.has_method("_die"):
		Autoload1.last_checkpoint = global_position
