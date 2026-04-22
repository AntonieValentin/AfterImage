extends TileMapLayer

# --- CONFIGURARE ---
const LATIME_HARTA = 300
const INALTIME_HARTA = 25
const NIVEL_PODEA = 18

const ID_IARBA = 3 
const IDS_PAMANT = [4, 5, 8, 9] 

const ZONA_SIGURANTA = 20

# SETĂRI REVIZUITE PENTRU MAI PUȚINE PRĂPĂSTII
const SANSA_GRAPA = 0.1   # Doar 4% șansă (mult mai puține)
const MIN_DISTANTA_INTRE_GRAPI = 15 # Minim 15 blocuri de pământ între două gropi

# Controlul parcurgerii
var ultima_x = 20
var ultima_y = NIVEL_PODEA
var x_ultima_grapa = 0

func _ready() -> void:
	clear()
	randomize()
	generate_level()

func generate_level():
	# 1. GENERĂM PODEAUA (cu reguli stricte pentru prăpăstii)
	var x_podea = 0
	while x_podea < LATIME_HARTA:
		var safe = (x_podea < ZONA_SIGURANTA) or (x_podea > LATIME_HARTA - ZONA_SIGURANTA)
		
		# Verificăm dacă putem face o groapă aici
		# Trebuie să NU fie zonă safe, să avem noroc la "zaruri" ȘI să fi trecut destul timp de la ultima groapă
		if !safe and randf() < SANSA_GRAPA and (x_podea - x_ultima_grapa) > MIN_DISTANTA_INTRE_GRAPI:
			var latime_grapa = randi_range(2, 5)
			x_podea += latime_grapa
			x_ultima_grapa = x_podea # Resetăm cronometrul de distanță
			continue
			
		# Desenăm coloana de pământ
		set_cell(Vector2i(x_podea, NIVEL_PODEA), ID_IARBA, Vector2i(0, 0))
		for y in range(NIVEL_PODEA + 1, INALTIME_HARTA):
			set_cell(Vector2i(x_podea, y), IDS_PAMANT.pick_random(), Vector2i(0, 0))
		x_podea += 1

	# 2. GENERĂM TRASEUL DE PLATFORME (Lănțuit pentru a fi săribil)
	ultima_x = ZONA_SIGURANTA
	ultima_y = NIVEL_PODEA
	
	while ultima_x < LATIME_HARTA - ZONA_SIGURANTA:
		var distanta_x = randi_range(4, 7) # Distanță mai mare între platforme (mai aerisit)
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
