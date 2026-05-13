extends CharacterBody2D

# setari miscare
@export var speed: float = 300.0
@export var jump_velocity: float = -400.0
@export var acceleration: float = 1500.0
@export var friction: float = 2000.0
@export var push_force: float = 100.0 # forta cu care impinge obiectele

@onready var tilemap: TileMapLayer = $"../TileMapLayer" 

# id-uri pentru interactiunea cu mediul
const ID_APA_FUND = 13
const ID_APA = 15
const ID_CIUPERCA = 16
const ID_TRAMBULINA = 17
const ID_COIN = 19

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var coins_session: int = 0
var ciuperci_session: int = 0
var clone_folosite: int = 0
var timp_start: float = 0.0

var pause_menu: CanvasLayer
var coins_label: Label
var ciuperci_label: Label

var hud: CanvasLayer
var hud_vieti: Label
var hud_coins: Label
var hud_ciuperci: Label

var vieti: int = 3
var vieti_label: Label
var checkpoint_uri: Array = []
var ultimul_checkpoint: Vector2 = Vector2.ZERO

func _ready():
	# retinem timpul la care a inceput nivelul
	timp_start = Time.get_ticks_msec() / 1000.0
	process_mode = Node.PROCESS_MODE_PAUSABLE
	_create_pause_menu()
	_create_hud()
	ultimul_checkpoint = global_position
	

func _physics_process(delta):
	# deschide meniul de pauza pe escape
	if Input.is_action_just_pressed("ui_cancel"):
		_toggle_pause()
	
	# porneste sau opreste inregistrarea pentru clona
	if Input.is_action_just_pressed("record"):
		_toggle_recording()

	# spawneaza clona care repeta miscarile
	if Input.is_action_just_pressed("execute"):
		_spawn_clone()

	# salveaza pozitia curenta daca inregistram
	if is_recording:
		_record_frame()
	
	# aplicam gravitatia daca nu suntem pe sol
	if not is_on_floor():
		velocity.y += gravity * delta

	# logica de saritura
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity * GameManager.get_jump_multiplier()

	# miscare stanga dreapta cu acceleratie si frictiune
	var direction = Input.get_axis("move_left", "move_right")
	if direction:
		velocity.x = move_toward(velocity.x, direction * speed, acceleration * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, friction * delta)
	
	move_and_slide()
	
	# verificam daca am atins apa sau iteme
	check_tile_interactions()
	check_usa()
	
	# detectare checkpointuri din tilemap
	var player_tile = tilemap.local_to_map(tilemap.to_local(global_position))
	for cp in checkpoint_uri:
		if player_tile.x >= cp.x - 1 and player_tile.x <= cp.x + 1:
			if cp.y == player_tile.y or cp.y == player_tile.y - 1:
				ultimul_checkpoint = global_position
	
	# logica pentru impins cutii (rigidbody2d)
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var body = collision.get_collider()
		if body is RigidBody2D:
			var push_dir = -collision.get_normal() 
			body.apply_central_impulse(push_dir * push_force)

func check_tile_interactions():
	if not tilemap: return

	# verificam daca picioarele jucatorului au atins apa
	var half_height: float = 16.0
	var foot_pos = global_position + Vector2(0, half_height)
	var foot_tile_pos = tilemap.local_to_map(tilemap.to_local(foot_pos))
	var foot_tile_id = tilemap.get_cell_source_id(foot_tile_pos)

	if foot_tile_id == ID_APA or foot_tile_id == ID_APA_FUND:
		_pierde_viata()
		return

	# verificam iteme la mijlocul si capul jucatorului
	var center_tile = tilemap.local_to_map(tilemap.to_local(global_position))
	var above_tile = center_tile + Vector2i(0, -1)

	_handle_pickup(center_tile)
	_handle_pickup(above_tile)

func _handle_pickup(coords: Vector2i):
	if not tilemap: return
	var id = tilemap.get_cell_source_id(coords)
	if id == ID_COIN:
		tilemap.erase_cell(coords)
		coins_session += 1
		_update_hud()  # ← ADĂUGAT
		print("Monede: ", coins_session)
	elif id == ID_CIUPERCA:
		tilemap.erase_cell(coords)
		ciuperci_session += 1
		_update_hud()  # ← ADĂUGAT
		print("Ciuperci: ", ciuperci_session)
	elif id == ID_TRAMBULINA:
		velocity.y = jump_velocity * 1.5
		
func check_usa():
	if not tilemap: return
	
	var player_grid_pos = tilemap.local_to_map(tilemap.to_local(global_position))
	
	# verificam daca jucatorul atinge usa (id 23) in jurul lui
	var tiles_de_verificat = [
		player_grid_pos,
		player_grid_pos + Vector2i(0, -1),
		player_grid_pos + Vector2i(1, 0), 
		player_grid_pos + Vector2i(-1, 0) 
	]
	
	for tile in tiles_de_verificat:
		if tilemap.get_cell_source_id(tile) == 23:
			_nivel_terminat()
			return 
		
func _nivel_terminat():
	var timp_nivel = Time.get_ticks_msec() / 1000.0 - timp_start
	var coins_castigate = coins_session + 200
	
	# bonusuri de performanta
	if timp_nivel < 60.0:
		coins_castigate += 50 
	if ciuperci_session >= 5:
		coins_castigate += 50 
	if clone_folosite <= 3:
		coins_castigate += 50 
	
	# salvare progres
	SaveManager.add_coins(coins_castigate)
	SaveManager.deblocheaza_nivel(GameManager.nivel_curent + 1)
	SaveManager.save_all_data()
	
	# trimitem datele catre ecranul de final
	GameManager.last_coins = coins_castigate
	GameManager.last_timp = timp_nivel
	GameManager.last_ciuperci = ciuperci_session
	GameManager.last_clone = clone_folosite
	
	get_tree().change_scene_to_file("res://EndGame.tscn")
	
# setup sistem de clone
const CLONE_SCENE = preload("res://clone.tscn")
var is_recording: bool = false
var recording_data: Array = []

func _toggle_recording() -> void:
	is_recording = !is_recording
	if is_recording:
		recording_data.clear()
		modulate = Color(1.5, 0.5, 0.5) # se face rosu cand inregistreaza
		print("Înregistrare pornită...")
	else:
		modulate = Color(1, 1, 1) # revine la culoarea normala
		print("Înregistrare oprită. Cadre salvate: ", recording_data.size())

func _record_frame() -> void:
	# salvam pozitia si directia sprite-ului pentru fiecare cadru
	var frame = {
		"pos": global_position,
		"flip": $Sprite2D.flip_h if has_node("Sprite2D") else false,
		"anim": "" 
	}
	recording_data.append(frame)

func _spawn_clone() -> void:
	if recording_data.is_empty():
		print("EROARE: Nu am ce să redau!")
		return
		
	# creeaza clona si ii da datele inregistrate
	var clone = CLONE_SCENE.instantiate()
	clone.playback_data = recording_data.duplicate()
	get_parent().add_child(clone)
	print("Clona a fost adăugată în scenă la: ", clone.global_position)
	
func _create_pause_menu():
	# creare meniu pauza din cod
	pause_menu = CanvasLayer.new()
	pause_menu.process_mode = Node.PROCESS_MODE_ALWAYS
	pause_menu.visible = false
	add_child(pause_menu)

	# fundal intunecat
	var bg = ColorRect.new()
	bg.color = Color(0, 0, 0, 0.6)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	pause_menu.add_child(bg)

	# container pentru butoane
	var vbox = VBoxContainer.new()
	vbox.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	vbox.add_theme_constant_override("separation", 20)
	vbox.offset_left = -150
	vbox.offset_right = 150
	vbox.offset_top = -180
	vbox.offset_bottom = 180
	pause_menu.add_child(vbox)

	var title = Label.new()
	title.text = "⏸ PAUSED"
	title.add_theme_font_size_override("font_size", 42)
	title.add_theme_color_override("font_color", Color("ffd700"))
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title)

	vbox.add_child(HSeparator.new())

	# afisare statistici in pauza
	coins_label = Label.new()
	coins_label.text = "🪙 Monede: 0"
	coins_label.add_theme_font_size_override("font_size", 26)
	coins_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(coins_label)

	ciuperci_label = Label.new()
	ciuperci_label.text = "🍄 Ciuperci: 0"
	ciuperci_label.add_theme_font_size_override("font_size", 26)
	ciuperci_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(ciuperci_label)
	
	vieti_label = Label.new()
	vieti_label.text = "❤️ Vieti: 3"
	vieti_label.add_theme_font_size_override("font_size", 26)
	vieti_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(vieti_label)

	vbox.add_child(HSeparator.new())

	# butoane meniu
	var btn_resume = Button.new()
	btn_resume.text = "▶ RESUME"
	btn_resume.custom_minimum_size = Vector2(250, 60)
	btn_resume.process_mode = Node.PROCESS_MODE_ALWAYS
	btn_resume.pressed.connect(_on_resume)
	vbox.add_child(btn_resume)

	var btn_menu = Button.new()
	btn_menu.text = "🏠 MAIN MENU"
	btn_menu.custom_minimum_size = Vector2(250, 60)
	btn_menu.process_mode = Node.PROCESS_MODE_ALWAYS
	btn_menu.pressed.connect(_on_exit_to_menu)
	vbox.add_child(btn_menu)

	var btn_quit = Button.new()
	btn_quit.text = "✕ QUIT"
	btn_quit.custom_minimum_size = Vector2(250, 60)
	btn_quit.process_mode = Node.PROCESS_MODE_ALWAYS
	btn_quit.pressed.connect(func(): get_tree().quit())
	vbox.add_child(btn_quit)
	
func _create_hud():
	hud = CanvasLayer.new()
	hud.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(hud)
	
	var hbox = HBoxContainer.new()
	hbox.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
	hbox.position = Vector2(20, 20)
	hbox.add_theme_constant_override("separation", 30)
	hud.add_child(hbox)
	
	hud_vieti = Label.new()
	hud_vieti.add_theme_font_size_override("font_size", 24)
	hud_vieti.add_theme_color_override("font_color", Color("ff4444"))
	hbox.add_child(hud_vieti)
	
	hud_coins = Label.new()
	hud_coins.add_theme_font_size_override("font_size", 24)
	hud_coins.add_theme_color_override("font_color", Color("ffd700"))
	hbox.add_child(hud_coins)
	
	hud_ciuperci = Label.new()
	hud_ciuperci.add_theme_font_size_override("font_size", 24)
	hud_ciuperci.add_theme_color_override("font_color", Color("aaffaa"))
	hbox.add_child(hud_ciuperci)
	
	_update_hud()

func _update_hud():
	hud_vieti.text = "❤️ %d" % vieti
	hud_coins.text = "🪙 %d" % coins_session
	hud_ciuperci.text = "🍄 %d" % ciuperci_session

func _toggle_pause():
	# schimba starea de pauza a jocului
	var is_paused = not get_tree().paused
	get_tree().paused = is_paused
	pause_menu.visible = is_paused
	if is_paused:
		coins_label.text = "🪙 Monede: %d" % coins_session
		ciuperci_label.text = "🍄 Ciuperci: %d" % ciuperci_session
		vieti_label.text = "❤️ Vieti: %d" % vieti

func _on_resume():
	get_tree().paused = false
	pause_menu.visible = false

func _on_exit_to_menu():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://MainMenu.tscn")
	
func _pierde_viata():
	vieti -= 1
	_update_hud()
	velocity = Vector2.ZERO
	if vieti <= 0:
		get_tree().change_scene_to_file("res://EndGame.tscn")
	else:
		global_position = ultimul_checkpoint
		print("Vieti ramase: ", vieti)
		if pause_menu.visible:
			vieti_label.text = "❤️ Vieti: %d" % vieti
