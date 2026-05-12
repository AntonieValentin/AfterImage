extends TileMapLayer

# --- CONFIGURARE ID-URI ---
const ID_IARBA = 3 
const IDS_PAMANT = [4, 5, 8, 9] 
const ID_APA_FUND = 13 # Apa pe care o vrei la fundul prăpastiilor

# --- PARAMETRI HARTA ---
const LATIME_HARTA = 300
const INALTIME_HARTA = 25
const NIVEL_PODEA = 18
const ZONA_SIGURANTA = 20

# --- SETĂRI PRĂPĂSTII ---
const SANSA_GRAPA = 0.1 # 10% șansă de prăpastie
const MIN_DISTANTA_INTRE_GRAPI = 15 

# Controlul parcurgerii
var ultima_x = 20
var ultima_y = NIVEL_PODEA
var x_ultima_grapa = -15 # Permite o groapă imediat după zona de start

func _ready() -> void:
	clear()
	randomize()
	# Setăm cerul o singură dată aici
	RenderingServer.set_default_clear_color(Color("87ceeb")) 
	generate_level()

func generate_level():
	print("--- GENERARE NIVEL CU APĂ LA FUND ---")
	
	# 1. GENERĂM PODEAUA ȘI APA DIN PRĂPĂSTII
	var x_podea = 0
	while x_podea < LATIME_HARTA:
		var safe = (x_podea < ZONA_SIGURANTA) or (x_podea > LATIME_HARTA - ZONA_SIGURANTA)
		
		# Verificăm dacă facem o prăpastie
		if !safe and randf() < SANSA_GRAPA and (x_podea - x_ultima_grapa) > MIN_DISTANTA_INTRE_GRAPI:
			var latime_grapa = randi_range(2, 5)
			
			# Desenăm APA pe fundul prăpastiei (pe ultimul rând)
			for i in range(latime_grapa):
				var curr_x = x_podea + i
				if curr_x < LATIME_HARTA:
					set_cell(Vector2i(curr_x, INALTIME_HARTA - 3), ID_APA_FUND, Vector2i(0, 0))
			
			x_ultima_grapa = x_podea
			x_podea += latime_grapa
			continue
			
		# Desenăm coloana de pământ normală
		set_cell(Vector2i(x_podea, NIVEL_PODEA), ID_IARBA, Vector2i(0, 0))
		for y in range(NIVEL_PODEA + 1, INALTIME_HARTA):
			set_cell(Vector2i(x_podea, y), IDS_PAMANT.pick_random(), Vector2i(0, 0))
		x_podea += 1

	# 2. GENERĂM TRASEUL DE PLATFORME (Lănțuit)
	ultima_x = ZONA_SIGURANTA
	ultima_y = NIVEL_PODEA
	
	while ultima_x < LATIME_HARTA - ZONA_SIGURANTA:
		var distanta_x = randi_range(4, 7)
		var schimbare_y = randi_range(-2, 2) 
		var inaltime_noua = clamp(ultima_y + schimbare_y, NIVEL_PODEA - 6, NIVEL_PODEA - 3)
		
		generate_platform_fixed(ultima_x + distanta_x, inaltime_noua)
		
		# Avansăm cursorul pentru următoarea platformă
		var lungime_platforma = 5 # Lungimea medie pentru calculul distanței
		ultima_x += distanta_x + lungime_platforma
		ultima_y = inaltime_noua

func generate_platform_fixed(start_x, y):
	var lungime = randi_range(3, 5)
	for i in range(lungime):
		var check_x = start_x + i
		if check_x < LATIME_HARTA - ZONA_SIGURANTA:
			set_cell(Vector2i(check_x, y), ID_IARBA, Vector2i(0, 0))
