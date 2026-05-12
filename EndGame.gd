extends Control

func _ready():
	# 1. LOGICA DE SALVARE (Trebuie să fie PRIMA linie)
	# Căutăm profilul (ex: Alex) în listă și îl încărcăm
	SaveManager.login_user(GameManager.player_name)
	
	# Adăugăm monedele câștigate acum la balanța lui din JSON
	SaveManager.add_coins(GameManager.last_coins)
	
	# Deblocăm nivelul următor în fișierul lui de salvare
	var id_nivel_urmator = GameManager.nivel_curent + 1
	SaveManager.deblocheaza_nivel(id_nivel_urmator)

	# --- CONFIGURARE UI (Codul tău, optimizat) ---
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	
	var vbox = VBoxContainer.new()
	vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	vbox.add_theme_constant_override("separation", 20)
	vbox.position = Vector2(50, 50)
	add_child(vbox)
	
	var title = Label.new()
	title.text = "NIVEL TERMINAT!"
	title.add_theme_font_size_override("font_size", 48)
	vbox.add_child(title)
	
	# Opțional: Afișăm cine a terminat (Alex / Guest)
	var name_label = Label.new()
	name_label.text = "Jucător: %s" % GameManager.player_name
	name_label.add_theme_font_size_override("font_size", 24)
	vbox.add_child(name_label)
	
	var coins_label = Label.new()
	coins_label.text = "Coins câștigate: %d" % GameManager.last_coins
	coins_label.add_theme_font_size_override("font_size", 28)
	vbox.add_child(coins_label)
	
	var timp_label = Label.new()
	timp_label.text = "Timp: %.1f secunde" % GameManager.last_timp
	timp_label.add_theme_font_size_override("font_size", 24)
	vbox.add_child(timp_label)
	
	var ciuperci_label = Label.new()
	ciuperci_label.text = "Ciuperci: %d/5" % GameManager.last_ciuperci
	ciuperci_label.add_theme_font_size_override("font_size", 24)
	vbox.add_child(ciuperci_label)
	
	var balanta_label = Label.new()
	# Acum get_balanta() va returna suma corectă a profilului curent
	balanta_label.text = "Balanță totală: %d coins" % SaveManager.get_balanta()
	balanta_label.add_theme_font_size_override("font_size", 24)
	vbox.add_child(balanta_label)
	
	# --- BUTON NIVEL URMATOR ---
	var nivel_urmator = GameManager.nivel_curent + 1
	# Verificăm dacă nivelul următor există (maxim 3) ȘI dacă este deblocat în SaveManager
	if nivel_urmator <= 3 and nivel_urmator <= SaveManager.get_nivel_deblocat():
		var btn_next = Button.new()
		btn_next.text = "Nivel %d" % nivel_urmator
		btn_next.custom_minimum_size = Vector2(200, 60)
		btn_next.add_theme_font_size_override("font_size", 24)
		btn_next.pressed.connect(_on_next_level)
		vbox.add_child(btn_next)
	
	var btn_menu = Button.new()
	btn_menu.text = "Meniu Principal"
	btn_menu.custom_minimum_size = Vector2(200, 60)
	btn_menu.add_theme_font_size_override("font_size", 24)
	btn_menu.pressed.connect(_on_menu)
	vbox.add_child(btn_menu)

func _on_next_level():
	# Creștem nivelul și reîncărcăm scena de nivele
	GameManager.nivel_curent += 1
	get_tree().change_scene_to_file("res://Levels.tscn")

func _on_menu():
	get_tree().change_scene_to_file("res://MainMenu.tscn")
