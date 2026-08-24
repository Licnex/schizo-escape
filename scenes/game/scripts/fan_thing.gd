extends Node2D

@onready var physical_hitbox: CollisionShape2D = $PhysicalBox/PhysicalHitbox
@onready var wind_and_air_hitbox: CollisionShape2D = $WindAndAir/WindAndAirHitbox
@onready var pointing_direction = physical_hitbox.global_position.direction_to(wind_and_air_hitbox.global_position) #gets the direction the fan is pointing

const WIND_FORCE = 1800.0 #the force that will be applied to the player

var bodies_in_wind: Array[Node2D] = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	for body in bodies_in_wind:
		body.velocity.y += pointing_direction.y*WIND_FORCE * delta
		body.velocity.x += pointing_direction.x*WIND_FORCE * delta
	print(pointing_direction)




#checks to see if a body has entered the fan air flow
func _on_wind_and_air_body_entered(body: Node2D) -> void:
	if body is StaticBody2D:
		pass
	else:
		bodies_in_wind.append(body)

#checks to see if a body has exited the fan air flow
func _on_wind_and_air_body_exited(body: Node2D) -> void:
	if body is StaticBody2D:
		pass
	else:
		bodies_in_wind.erase(body)
