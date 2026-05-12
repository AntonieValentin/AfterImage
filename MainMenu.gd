extends Control

func _ready():
	# Configurare fundal și container
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	
	var vbox = VBoxContainer.new()
	vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	vbox.add_theme_constant_override("separation", 20)
	vbox.position = Vector2(50, 50)
	add_child(vbox)
	
	# --- TITLU / PREVIZUALIZARE NUME ---
	var user_display = Label.new()
	# La pornire, încercăm să luăm ultimul nume din GameManager
	user_display.text = GameManager.player_name.to_upper() if GameManager.player_name != "" else "GUEST"
	user_display.add_theme_font_size_override("font_size", 42)
	vbox.add_child(user_display)
	
	# --- LINEEDIT (Câmpul de text) ---
	var name_edit = LineEdit.new()
	name_edit.placeholder_text = "SCRIE NUMELE PENTRU SALVARE..."
	name_edit.custom_minimum_size = Vector2(350, 45)
	name_edit.text = GameManager.player_name
	
	# CONECTARE: Aici facem "Logarea" în sistemul Multi-User
	name_edit.text_changed.connect(func(new_name):
		# 1. Actualizăm numele în memoria temporară
		GameManager.set_player_name(new_name)
		
		# 2. Îi spunem SaveManager-ului cine este utilizatorul activ
		# Această funcție va căuta în listă sau va crea un profil nou la final
		SaveManager.login_user(new_name)
		
		# 3. Actualizăm textul de sus
		user_display.text = new_name.to_upper() if new_name != "" else "GUEST"
	)
	vbox.add_child(name_edit)

	# --- LABEL START GAME ---
	var start_label = Label.new()
	start_label.text = "START GAME"
	start_label.add_theme_font_size_override("font_size", 32)
	start_label.add_theme_color_override("font_color", Color("ffd700"))
	vbox.add_child(start_label)
	
	var hbox = HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 15)
	vbox.add_child(hbox)
	
	# Butoane Dificultate
	var btn_noob = Button.new()
	btn_noob.text = "NOOB MODE"
	btn_noob.custom_minimum_size = Vector2(180, 65)
	btn_noob.pressed.connect(_on_noob_pressed)
	hbox.add_child(btn_noob)
	
	var btn_pro = Button.new()
	btn_pro.text = "PRO MODE"
	btn_pro.custom_minimum_size = Vector2(180, 65)
	btn_pro.pressed.connect(_on_pro_pressed)
	hbox.add_child(btn_pro)
	
	var btn_quit = Button.new()
	btn_quit.text = "QUIT"
	btn_quit.pressed.connect(func(): get_tree().quit())
	vbox.add_child(btn_quit)

func _on_noob_pressed():
	GameManager.set_difficulty(true)
	# Forțăm o ultimă logare înainte de start pentru siguranță
	SaveManager.login_user(GameManager.player_name)
	get_tree().change_scene_to_file("res://Levels.tscn")

func _on_pro_pressed():
	GameManager.set_difficulty(false)
	SaveManager.login_user(GameManager.player_name)
	get_tree().change_scene_to_file("res://Levels.tscn")
