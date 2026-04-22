extends CharacterBody2D

@export var speed: float = 300.0
@export var jump_velocity: float = -400.0
@export var acceleration: float = 1500.0
@export var friction: float = 2000.0

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _physics_process(delta):
	# Gravitate
	if not is_on_floor():
		velocity.y += gravity * delta

	# Săritură (asigură-te că ai "jump" în Input Map)
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity

	# Direcție (asigură-te că ai "move_left" și "move_right" în Input Map)
	var direction = Input.get_axis("move_left", "move_right")
	
	if direction:
		velocity.x = move_toward(velocity.x, direction * speed, acceleration * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, friction * delta)

	move_and_slide()
