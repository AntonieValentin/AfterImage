extends Node

# date utilizator si salvare
var player_name: String = "Guest" # numele care apare in meniu si in save
var coins_total: int = 0

# setari dificultate
var is_noob_mode: bool = true

# parametri noob (mai usor)
const NOOB_CLONE_DURATION = 8.0
const NOOB_CLONE_BONUS = 3
const NOOB_JUMP_MULTIPLIER = 1.3

# parametri pro (mai greu)
const PRO_CLONE_DURATION = 6.0
const PRO_CLONE_BONUS = 0
const PRO_JUMP_MULTIPLIER = 1.0

# statistici sesiune pentru ecranul de final
var nivel_curent: int = 1
var last_coins: int = 0
var last_timp: float = 0.0
var last_ciuperci: int = 0
var last_clone: int = 0

# returneaza durata de viata a unei clone
func get_clone_duration() -> float:
	return NOOB_CLONE_DURATION if is_noob_mode else PRO_CLONE_DURATION

# returneaza numarul de clone bonus in functie de mod
func get_clone_bonus() -> int:
	return NOOB_CLONE_BONUS if is_noob_mode else PRO_CLONE_BONUS

# returneaza cat de sus sare jucatorul
func get_jump_multiplier() -> float:
	return NOOB_JUMP_MULTIPLIER if is_noob_mode else PRO_JUMP_MULTIPLIER

# seteaza modul de joc (noob sau pro)
func set_difficulty(noob: bool):
	is_noob_mode = noob

# salveaza numele nou si verifica sa nu fie gol
func set_player_name(new_name: String):
	if new_name.strip_edges() == "":
		player_name = "Guest"
	else:
		player_name = new_name
