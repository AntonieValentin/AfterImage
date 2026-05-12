extends CharacterBody2D

# Această listă va fi umplută de Player când instanțiază clona
var playback_data: Array = []
var current_frame: int = 0

func _ready() -> void:
	# Feedback vizual: clona este "fantomă" (semi-transparentă)
	modulate.a = 0.5

func _physics_process(_delta: float) -> void:
	# Verificăm dacă mai avem cadre de redat
	if current_frame < playback_data.size():
		var data = playback_data[current_frame]
		
		# Sincronizăm clona cu datele înregistrate
		global_position = data["pos"]
		
		# Actualizăm animația și direcția vizuală
		if has_node("Sprite2D"):
			$Sprite2D.flip_h = data["flip"]
		
		if data["anim"] != "" and has_node("AnimationPlayer"):
			$AnimationPlayer.play(data["anim"])
		
		# Trecem la următorul moment înregistrat
		current_frame += 1
	else:
		# Dacă am terminat lista, clona dispare
		queue_free()
