extends Camera2D

@export var viteza: float = 600.0
# Lungimea hărții tale (300 tiles * 16 pixeli per tile = 4800 pixeli)
# Ajustează 4800 dacă tile-urile tale au altă dimensiune (ex: 32x32)
@export var limita_dreapta: float = 4086.0 


func _process(delta: float) -> void:
	var directie = Input.get_axis("ui_left", "ui_right")
	
	if Input.is_key_pressed(KEY_A): directie = -1
	if Input.is_key_pressed(KEY_D): directie = 1
	
	# Calculăm noua poziție dorită
	var noua_pozitie_x = position.x + directie * viteza * delta
	
	# LIMITAREA (Aici e magia):
	# clamp(valoare, minim, maxim)
	# 0 = marginea din stânga
	# limita_dreapta = marginea din dreapta
	position.x = clamp(noua_pozitie_x, 0, limita_dreapta)
