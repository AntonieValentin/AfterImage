extends CharacterBody2D

# Setari pt miscare (le poti modifica din Inspector)
@export var speed: float = 300.0
@export var jump_velocity: float = -400.0
@export var acceleration: float = 1500.0
@export var friction: float = 2000.0

# Iau gravitatia default din project settings
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _physics_process(delta):
	# Gravitatie daca e in aer
	if not is_on_floor():
		velocity.y += gravity * delta

	# Saritura
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity

	# Miscare stanga-dreapta (-1, 1 sau 0)
	var direction = Input.get_axis("move_left", "move_right")
	
	if direction:
		# Bagam viteza spre directia apasata
		velocity.x = move_toward(velocity.x, direction * speed, acceleration * delta)
		
		# Decomenteaza bucata asta ca sa intorci imaginea personajului cand schimbi directia:
		# if direction < 0:
		#     $Sprite2D.flip_h = true
		# elif direction > 0:
		#     $Sprite2D.flip_h = false
	else:
		# Frecare ca sa se opreasca natural cand iei mana de pe taste (sa nu alunece ca pe gheata)
		velocity.x = move_toward(velocity.x, 0, friction * delta)

	# Muta personajul efectiv si calculeaza coliziunile cu podeaua/peretii
	move_and_slide()
