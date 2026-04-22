extends TileMapLayer

# --- CONFIGURARE ---
const LATIME_HARTA = 300
const INALTIME_HARTA = 25
const NIVEL_PODEA = 18

const ID_IARBA = 3 
const IDS_PAMANT = [4, 5, 8, 9] 

const ZONA_SIGURANTA = 20

# --- MODIFICARE: Referință către Player ---
# Această linie îți permite să tragi nodul Player din scenă direct în Inspector
@export var player: CharacterBody2D 

# Controlul parcurgerii
var ultima_x = 20
var ultima_y = NIVEL_PODEA
var x_ultima_grapa = 0

func _ready() -> void:
	clear()
	randomize()
	generate_level()
	# --- MODIFICARE: Apelăm poziționarea jucătorului ---
	spawn_player()

func spawn_player():
	# Verificăm dacă am legat jucătorul în Inspector
	if player:
		# Alegem un punct în ZONA_SIGURANTA (de ex. x=5)
		# y trebuie să fie NIVEL_PODEA - 1 (ca să stea deasupra ierbii, nu în ea)
		var coordonate_dala = Vector2i(5, NIVEL_PODEA - 3)
		
		# map_to_local transformă (5, 16) dale în pixeli reali (ex: 80px, 256px)
		var pozitie_pixeli = map_to_local(coordonate_dala)
		
		# Setăm poziția globală a jucătorului
		player.global_position = pozitie_pixeli
		print("Player a fost teleportat la: ", pozitie_pixeli)
	else:
		print("EROARE: Nu ai uitat să tragi nodul Player în Inspector?")

func generate_level():
	# 1. GENERĂM PODEAUA
	var x_podea = 0
	while x_podea < LATIME_HARTA:
		var safe = (x_podea < ZONA_SIGURANTA) or (x_podea > LATIME_HARTA - ZONA_SIGURANTA)
		
		if !safe and randf() < 0.1 and (x_podea - x_ultima_grapa) > 15:
			var latime_grapa = randi_range(2, 5)
			x_podea += latime_grapa
			x_ultima_grapa = x_podea
			continue
			
		set_cell(Vector2i(x_podea, NIVEL_PODEA), ID_IARBA, Vector2i(0, 0))
		for y in range(NIVEL_PODEA + 1, INALTIME_HARTA):
			set_cell(Vector2i(x_podea, y), IDS_PAMANT.pick_random(), Vector2i(0, 0))
		x_podea += 1

	# 2. GENERĂM TRASEUL DE PLATFORME
	ultima_x = ZONA_SIGURANTA
	ultima_y = NIVEL_PODEA
	
	while ultima_x < LATIME_HARTA - ZONA_SIGURANTA:
		var distanta_x = randi_range(4, 7)
		var schimbare_y = randi_range(-2, 2) 
		var inaltime_noua = clamp(ultima_y + schimbare_y, NIVEL_PODEA - 6, NIVEL_PODEA - 3)
		
		generate_platform_fixed(ultima_x + distanta_x, inaltime_noua)
		
		ultima_x += distanta_x + 4
		ultima_y = inaltime_noua

func generate_platform_fixed(start_x, y):
	var lungime = randi_range(3, 5)
	for i in range(lungime):
		if start_x + i < LATIME_HARTA - ZONA_SIGURANTA:
			set_cell(Vector2i(start_x + i, y), ID_IARBA, Vector2i(0, 0))
