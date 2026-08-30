extends RigidBody2D
@onready var particles: CPUParticles2D = $CPUParticles2D
@onready var sprite: Sprite2D = $Sprite2D



func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is not CharacterBody2D:
		_hit_wall()


func _hit_wall():
	particles.emitting = true
	sprite.visible = false

func _on_cpu_particles_2d_finished() -> void:
	queue_free()
