extends Node

const SAVE_PATH = "user://savegame.json"

var all_profiles = [] # lista cu toti userii din fisier
var current_data = {} # datele profilului activ

func _ready():
	load_all_data()

func load_all_data():
	# daca nu exista fisierul de save, incepem cu o lista goala
	if not FileAccess.file_exists(SAVE_PATH):
		all_profiles = []
		return
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	var content = file.get_as_text()
	file.close()
	
	# incarcam datele din json in array-ul de profile
	var parsed = JSON.parse_string(content)
	if parsed is Array:
		all_profiles = parsed
	else:
		all_profiles = []

func login_user(username: String):
	load_all_data()
	var gasit = false
	# cautam daca exista deja numele asta in lista
	for p in all_profiles:
		if p["player_name"].to_lower() == username.to_lower():
			current_data = p
			gasit = true
			break
	
	# daca e jucator nou, ii facem profil acum
	if not gasit:
		current_data = {
			"player_name": username,
			"coins_balanta": 0,
			"high_score": 0,
			"nivel_deblocat": 1
		}
		all_profiles.append(current_data)
	
	save_all_data()

# functii de logica joc

func add_coins(amount: int):
	# daca nu e nimeni logat, punem pe guest
	if current_data.is_empty(): login_user("Guest")
	current_data["coins_balanta"] += amount
	
	# verificam daca am batut recordul vechi
	if amount > current_data.get("high_score", 0):
		current_data["high_score"] = amount
	save_all_data()

func deblocheaza_nivel(nivel: int):
	if current_data.is_empty(): login_user("Guest")
	
	# facem update doar daca nivelul nou e mai mare decat ce aveam
	if nivel > current_data.get("nivel_deblocat", 1):
		current_data["nivel_deblocat"] = nivel
		save_all_data()
		print("S-a deblocat nivelul: ", nivel)

#functii de acces date

func save_all_data():
	# bagam datele curente inapoi in lista inainte sa salvam pe disc
	for i in range(all_profiles.size()):
		if all_profiles[i]["player_name"] == current_data["player_name"]:
			all_profiles[i] = current_data
	
	# scriem totul in fisier formatat
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	file.store_string(JSON.stringify(all_profiles, "\t"))
	file.close()

func get_balanta() -> int:
	return current_data.get("coins_balanta", 0)

func get_highscore() -> int:
	return current_data.get("high_score", 0)

func get_nivel_deblocat() -> int:
	return current_data.get("nivel_deblocat", 1)
