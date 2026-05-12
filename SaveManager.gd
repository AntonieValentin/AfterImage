extends Node

const SAVE_PATH = "user://savegame.json"

var all_profiles = [] # Lista cu toți jucătorii din baza de date
var current_data = {} # Datele profilului pe care jucăm acum

func _ready():
	load_all_data()

func load_all_data():
	if not FileAccess.file_exists(SAVE_PATH):
		all_profiles = []
		return
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	var content = file.get_as_text()
	file.close()
	
	var parsed = JSON.parse_string(content)
	if parsed is Array:
		all_profiles = parsed
	else:
		all_profiles = []

func login_user(username: String):
	load_all_data()
	var gasit = false
	for p in all_profiles:
		if p["player_name"].to_lower() == username.to_lower():
			current_data = p
			gasit = true
			break
	
	if not gasit:
		current_data = {
			"player_name": username,
			"coins_balanta": 0,
			"high_score": 0,
			"nivel_deblocat": 1
		}
		all_profiles.append(current_data)
	
	save_all_data()

# --- FUNCTII DE LOGICA JOC (PENTRU PLAYER / ENDGAME) ---

func add_coins(amount: int):
	if current_data.is_empty(): login_user("Guest")
	current_data["coins_balanta"] += amount
	
	# Update Highscore (Scorul maxim obținut într-un nivel)
	if amount > current_data.get("high_score", 0):
		current_data["high_score"] = amount
	save_all_data()

# ACEASTA ESTE FUNCTIA CARE LIPSEA:
func deblocheaza_nivel(nivel: int):
	if current_data.is_empty(): login_user("Guest")
	
	# Dacă nivelul terminat e mai mare decât ce aveam deblocat, facem update
	if nivel > current_data.get("nivel_deblocat", 1):
		current_data["nivel_deblocat"] = nivel
		save_all_data()
		print("S-a deblocat nivelul: ", nivel)

# --- FUNCTII DE ACCES DATE ---

func save_all_data():
	# Sincronizăm profilul curent în lista mare înainte de scriere
	for i in range(all_profiles.size()):
		if all_profiles[i]["player_name"] == current_data["player_name"]:
			all_profiles[i] = current_data
	
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	file.store_string(JSON.stringify(all_profiles, "\t"))
	file.close()

func get_balanta() -> int:
	return current_data.get("coins_balanta", 0)

func get_highscore() -> int:
	return current_data.get("high_score", 0)

func get_nivel_deblocat() -> int:
	return current_data.get("nivel_deblocat", 1)
