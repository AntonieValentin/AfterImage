extends CharacterBody2D

# Setări mișcare
@export var speed: float = 300.0
@export var jump_velocity: float = -400.0
@export var acceleration: float = 1500.0
@export var friction: float = 2000.0
@export var push_force: float = 100.0 # Puterea cu care împingi cutiile

@onready var tilemap: TileMapLayer = $"../TileMapLayer" 

# Referințe ID-uri peantru interacțiune
const ID_APA_FUND = 13
const ID_APA = 15
const ID_CIUPERCA = 16
const ID_TRAMBULINA = 17
const ID_COIN = 19

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var coins_session: int = 0
var ciuperci_session: int = 0
var clone_folosite: int = 0
var timp_start: float = 0.0

func _ready():
	timp_start = Time.get_ticks_msec() / 1000.0

func _physics_process(delta):
	# Gravitatie
	if not is_on_floor():
		velocity.y += gravity * delta

	# Saritura
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity * GameManager.get_jump_multiplier()

	# Miscare orizontala
	var direction = Input.get_axis("move_left", "move_right")
	if direction:
		velocity.x = move_toward(velocity.x, direction * speed, acceleration * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, friction * delta)
	var current_id = tilemap.get_cell_source_id(tilemap.local_to_map(tilemap.to_local(global_position)))
	# Mută personajul
	move_and_slide()
	
	# --- NOU: DETECTARE APĂ (GAME OVER) ȘI COLECTABILE ---
	check_tile_interactions()
	check_usa()
	
	
		# FIX CUTII: folosim normala coliziunii direct (fără negare)
	# collision.get_normal() indică direcția DE LA obiect SPRE personaj
	# deci negarea ei (-normal) = direcția în care personajul împinge cutia
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var body = collision.get_collider()
		if body is RigidBody2D:
			var push_dir = -collision.get_normal()  # direcția de împingere corectă
			body.apply_central_impulse(push_dir * push_force)

func check_tile_interactions():
	if not tilemap: return

	# FIX APĂ: offset mai mare (jumătate din înălțimea sprite-ului, ex. 16px)
	# Ajustează 16.0 la jumătate din înălțimea reală a personajului tău
	var half_height: float = 16.0
	var foot_pos = global_position + Vector2(0, half_height)
	var foot_tile_pos = tilemap.local_to_map(tilemap.to_local(foot_pos))
	var foot_tile_id = tilemap.get_cell_source_id(foot_tile_pos)

	if foot_tile_id == ID_APA or foot_tile_id == ID_APA_FUND:
		get_tree().reload_current_scene()
		return

	# Colectabile — verificăm tile-ul personajului și cel de deasupra
	var center_tile = tilemap.local_to_map(tilemap.to_local(global_position))
	var above_tile = center_tile + Vector2i(0, -1)

	_handle_pickup(center_tile)
	_handle_pickup(above_tile)

func _handle_pickup(coords: Vector2i):
	if not tilemap: return
	var id = tilemap.get_cell_source_id(coords)
	if id == ID_COIN:
		tilemap.erase_cell(coords)
		coins_session += 1
	elif id == ID_CIUPERCA:
		tilemap.erase_cell(coords)
		ciuperci_session += 1
	elif id == ID_TRAMBULINA:
		velocity.y = jump_velocity * 1.5
		
func check_usa():
	if not tilemap: return
	
	# Luăm poziția picioarelor jucătorului și o transformăm în coordonate de grilă
	var player_grid_pos = tilemap.local_to_map(tilemap.to_local(global_position))
	
	# Verificăm o zonă mică în jurul jucătorului (picioare și mijloc)
	# pentru a fi siguri că detectăm ușa (ID 23)
	var tiles_de_verificat = [
		player_grid_pos,
		player_grid_pos + Vector2i(0, -1), # Un tile mai sus
		player_grid_pos + Vector2i(1, 0),  # Un tile la dreapta
		player_grid_pos + Vector2i(-1, 0)  # Un tile la stânga
	]
	
	for tile in tiles_de_verificat:
		if tilemap.get_cell_source_id(tile) == 23: # 23 este ID_USA definit de tine
			_nivel_terminat()
			return # Ieșim din funcție imediat ce am găsit ușa
		
func _nivel_terminat():
	var timp_nivel = Time.get_ticks_msec() / 1000.0 - timp_start
	
	# Coins de bază
	var coins_castigate = coins_session + 200
	
	# Obiective bonus
	if timp_nivel < 60.0:
		coins_castigate += 50  # Time Attack
	if ciuperci_session >= 5:
		coins_castigate += 50  # Colectare
	if clone_folosite <= 3:
		coins_castigate += 50  # Eficiență
	
	SaveManager.add_coins(coins_castigate)
	SaveManager.deblocheaza_nivel(GameManager.nivel_curent + 1)
	SaveManager.save_all_data()
	
	# Trimite datele la ecranul de EndGame
	GameManager.last_coins = coins_castigate
	GameManager.last_timp = timp_nivel
	GameManager.last_ciuperci = ciuperci_session
	GameManager.last_clone = clone_folosite
	
	get_tree().change_scene_to_file("res://EndGame.tscn")
