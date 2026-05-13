extends Node

# date utilizator si salvare
var player_name: String = "Guest" # numele implicit din main menu
var coins_total: int = 0

# setari dificultate
var is_noob_mode: bool = true

# parametri noob
const NOOB_CLONE_DURATION = 8.0
const NOOB_CLONE_BONUS = 3
const NOOB_JUMP_MULTIPLIER = 1.3

# parametri pro
const PRO_CLONE_DURATION = 6.0
const PRO_CLONE_BONUS = 0
const PRO_JUMP_MULTIPLIER = 1.0

# statistici sesiune pentru endgame
var nivel_curent: int = 1
var last_coins: int = 0
var last_timp: float = 0.0
var last_ciuperci: int = 0
var last_clone: int = 0

# returneaza durata clonei in functie de mod
func get_clone_duration() -> float:
	return NOOB_CLONE_DURATION if is_noob_mode else PRO_CLONE_DURATION

# returneaza bonusul de clone
func get_clone_bonus() -> int:
	return NOOB_CLONE_BONUS if is_noob_mode else PRO_CLONE_BONUS

# returneaza multiplicatorul pentru saritura
func get_jump_multiplier() -> float:
	return NOOB_JUMP_MULTIPLIER if is_noob_mode else PRO_JUMP_MULTIPLIER

# schimba modul de dificultate
func set_difficulty(noob: bool):
	is_noob_mode = noob

# seteaza numele si pune guest daca ramane gol
func set_player_name(new_name: String):
	if new_name.strip_edges() == "":
		player_name = "Guest"
	else:
		player_name = new_name
