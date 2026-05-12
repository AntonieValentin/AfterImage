extends Node

	# --- DATE UTILIZATOR ȘI SALVARE ---
var player_name: String = "Guest" # Numele implicit care va fi cerut în Main Menu
var coins_total: int = 0

	# --- SETĂRI DIFICULTATE ---
var is_noob_mode: bool = true

	# Parametri Noob
const NOOB_CLONE_DURATION = 8.0
const NOOB_CLONE_BONUS = 3
const NOOB_JUMP_MULTIPLIER = 1.3

	# Parametri Pro  
const PRO_CLONE_DURATION = 6.0
const PRO_CLONE_BONUS = 0
const PRO_JUMP_MULTIPLIER = 1.0

	# --- STATISTICI SESIUNE (Pentru EndGame) ---
var nivel_curent: int = 1
var last_coins: int = 0
var last_timp: float = 0.0
var last_ciuperci: int = 0
var last_clone: int = 0

	# --- FUNCȚII ACCES ---
func get_clone_duration() -> float:
	return NOOB_CLONE_DURATION if is_noob_mode else PRO_CLONE_DURATION

func get_clone_bonus() -> int:
	return NOOB_CLONE_BONUS if is_noob_mode else PRO_CLONE_BONUS

func get_jump_multiplier() -> float:
	return NOOB_JUMP_MULTIPLIER if is_noob_mode else PRO_JUMP_MULTIPLIER

func set_difficulty(noob: bool):
	is_noob_mode = noob

	# --- LOGICĂ NUME ---
func set_player_name(new_name: String):
	if new_name.strip_edges() == "":
		player_name = "Guest"
	else:
		player_name = new_name
