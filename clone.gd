extends CharacterBody2D

# lista de cadre primita de la player la spawn
var playback_data: Array = []
var current_frame: int = 0

func _ready() -> void:
	# clona este semitransparenta ca sa para o copie
	modulate.a = 0.5
	
	# activam coliziunile ca sa poata fi folosita ca platforma
	collision_layer = 1 
	collision_mask = 1

func _physics_process(_delta: float) -> void:
	# verificam daca mai sunt cadre inregistrate de rulat
	if current_frame < playback_data.size():
		var data = playback_data[current_frame]
		
		# mutam clona exact pe pozitiile salvate din memorie
		global_position = data["pos"]
		
		# setam directia sprite-ului (stanga sau dreapta)
		if has_node("Sprite2D"):
			$Sprite2D.flip_h = data["flip"]
		
		# pornim animatia corecta pentru cadrul curent
		if data["anim"] != "" and has_node("AnimationPlayer"):
			$AnimationPlayer.play(data["anim"])
		
		# trecem la urmatoarea pozitie din lista
		current_frame += 1
	else:
		# cand se termina datele de redat clona este stearsa
		queue_free()
