extends Control

var hbox_levels: HBoxContainer

func _ready():
	# setam meniul pe tot ecranul
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	
	var vbox = VBoxContainer.new()
	vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	vbox.add_theme_constant_override("separation", 20)
	vbox.position = Vector2(50, 50)
	add_child(vbox)

	# nume jucator
	var user_display = Label.new()
	user_display.text = GameManager.player_name.to_upper()
	user_display.add_theme_font_size_override("font_size", 42)
	vbox.add_child(user_display)

	var name_edit = LineEdit.new()
	name_edit.placeholder_text = "SCRIE NUMELE PENTRU SALVARE..."
	name_edit.custom_minimum_size = Vector2(350, 45)
	name_edit.text = GameManager.player_name if GameManager.player_name != "Guest" else ""
	# actualizam textul in timp ce utilizatorul scrie
	name_edit.text_changed.connect(func(new_name):
		GameManager.set_player_name(new_name)
		user_display.text = GameManager.player_name.to_upper()
	)

# logare cand se apasa enter sau se schimba focusul
	name_edit.text_submitted.connect(func():
		SaveManager.login_user(GameManager.player_name)
		_rebuild_level_buttons()
	)

	name_edit.focus_exited.connect(func():
		SaveManager.login_user(GameManager.player_name)
		_rebuild_level_buttons()
	)
	vbox.add_child(name_edit)

	# dificultate
	var start_label = Label.new()
	start_label.text = "START GAME"
	start_label.add_theme_font_size_override("font_size", 32)
	start_label.add_theme_color_override("font_color", Color("ffd700"))
	vbox.add_child(start_label)

	var hbox_diff = HBoxContainer.new()
	hbox_diff.add_theme_constant_override("separation", 15)
	vbox.add_child(hbox_diff)

	var btn_noob = Button.new()
	btn_noob.text = "NOOB MODE"
	btn_noob.custom_minimum_size = Vector2(180, 65)
	btn_noob.pressed.connect(_on_noob_pressed)
	hbox_diff.add_child(btn_noob)

	var btn_pro = Button.new()
	btn_pro.text = "PRO MODE"
	btn_pro.custom_minimum_size = Vector2(180, 65)
	btn_pro.pressed.connect(_on_pro_pressed)
	hbox_diff.add_child(btn_pro)

	# selectare nivel
	var level_label = Label.new()
	level_label.text = "SELECT LEVEL"
	level_label.add_theme_font_size_override("font_size", 28)
	level_label.add_theme_color_override("font_color", Color("aaaaaa"))
	vbox.add_child(level_label)

	hbox_levels = HBoxContainer.new()
	hbox_levels.add_theme_constant_override("separation", 15)
	vbox.add_child(hbox_levels)

	# incarcam profilul inainte sa apara butoanele
	SaveManager.login_user(GameManager.player_name)
	_rebuild_level_buttons()

	# buton iesire
	var btn_quit = Button.new()
	btn_quit.text = "QUIT"
	btn_quit.pressed.connect(func(): get_tree().quit())
	vbox.add_child(btn_quit)


func _rebuild_level_buttons():
	# curatam lista de butoane
	for child in hbox_levels.get_children():
		child.queue_free()

	var nivel_deblocat = SaveManager.get_nivel_deblocat()

	# cream butoane pentru fiecare nivel de la 1 la 3
	for i in range(1, 4):
		var btn_level = Button.new()
		btn_level.custom_minimum_size = Vector2(120, 65)
		# verificam daca nivelul este accesibil
		if i <= nivel_deblocat:
			btn_level.text = "LEVEL %d" % i
			btn_level.pressed.connect(_on_level_pressed.bind(i))
		else:
			btn_level.text = "🔒 LEVEL %d" % i
			btn_level.pressed.connect(_on_level_locked.bind(i))
		hbox_levels.add_child(btn_level)


func _on_noob_pressed():
	GameManager.set_difficulty(true)

func _on_pro_pressed():
	GameManager.set_difficulty(false)

func _on_level_pressed(level: int):
	# pornim nivelul selectat
	GameManager.nivel_curent = level
	get_tree().change_scene_to_file("res://Levels.tscn")

func _on_level_locked(level: int):
	# afisam mesaj daca nivelul este blocat
	_show_notification("⛔ LEVEL %d IS LOCKED!" % level)

func _show_notification(message: String):
	# eliminam notificarea anterioara
	var old = get_node_or_null("Notification")
	if old:
		old.queue_free()

	var notif = Label.new()
	notif.name = "Notification"
	notif.text = message
	notif.add_theme_font_size_override("font_size", 26)
	notif.add_theme_color_override("font_color", Color("ff4444"))
	notif.set_anchors_and_offsets_preset(Control.PRESET_CENTER_BOTTOM)
	notif.position.y -= 80
	add_child(notif)

	# stergem mesajul automat dupa 2 secunde
	var timer = get_tree().create_timer(2.0)
	timer.timeout.connect(func():
		if is_instance_valid(notif):
			notif.queue_free()
	)
