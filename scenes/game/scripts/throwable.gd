extends RigidBody2D

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is not CharacterBody2D:
		queue_free()
