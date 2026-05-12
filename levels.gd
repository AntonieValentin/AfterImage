extends TileMapLayer

const ID_IARBA = 3
const IDS_PAMANT = [4, 5, 8, 9]
const ID_APA_FUND = 13
const ID_APA = 15
const ID_CIUPERCA = 16
const ID_TRAMBULINA = 17
const ID_COIN = 19
const ID_SEMN_STANGA = 22
const ID_SEMN_DREAPTA = 21
const ID_USA = 23

const NIVEL_PODEA = 18
const ZONA_SIGURANTA = 50
const SEED_NIVEL_1 = 12345
const SEED_NIVEL_2 = 54321

# Scena cutiei — asigură-te că path-ul e corect
const BOX_SCENE = preload("res://Box.tscn")
var usa_world_pos: Vector2 = Vector2.ZERO # Aceasta va fi citită de Player

func _ready() -> void:
	RenderingServer.set_default_clear_color(Color("87ceeb"))
	setup_level(1)

func setup_level(numar_nivel: int):
	match numar_nivel:
		1: generate_fixed_level(1500, SEED_NIVEL_1)
		2: generate_fixed_level(2000, SEED_NIVEL_2)
		3: generate_concatenated_level()

func generate_fixed_level(lungime: int, s_id: int):
	seed(s_id)
	clear()
	_build_terrain(lungime)
	_build_platforms_and_items(lungime)

func generate_concatenated_level():
	clear()
	seed(SEED_NIVEL_1)
	_build_terrain(500, 0)
	_build_platforms_and_items(500, 0)
	seed(SEED_NIVEL_2)
	_build_terrain(1000, 500)
	_build_platforms_and_items(1000, 500)

func _build_terrain(lungime: int, offset_x: int = 0):
	var x = 0
	var x_ultima_grapa = -ZONA_SIGURANTA
	while x < lungime:
		var curr_x = x + offset_x
		var safe = (x < ZONA_SIGURANTA) or (x > lungime - ZONA_SIGURANTA)
		if !safe and randf() < 0.1 and (x - x_ultima_grapa) > 15:
			var latime = randi_range(2, 4)
			for i in range(latime):
				set_cell(Vector2i(curr_x + i, NIVEL_PODEA + 2), ID_APA_FUND, Vector2i(0, 0))
				for y_apa in range(NIVEL_PODEA + 3, NIVEL_PODEA + 23):
					set_cell(Vector2i(curr_x + i, y_apa), ID_APA, Vector2i(0, 0))
			x_ultima_grapa = x
			x += latime
			continue
		set_cell(Vector2i(curr_x, NIVEL_PODEA), ID_IARBA, Vector2i(0, 0))
		for y in range(NIVEL_PODEA + 1, NIVEL_PODEA + 25):
			set_cell(Vector2i(curr_x, y), IDS_PAMANT.pick_random(), Vector2i(0, 0))
		if curr_x == 0 or (x == lungime - 1 and offset_x + lungime >= 1500):
			for y_zid in range(1, 15):
				set_cell(Vector2i(curr_x, NIVEL_PODEA - y_zid), IDS_PAMANT[0], Vector2i(0, 0))
		x += 1

func _build_platforms_and_items(lungime: int, offset_x: int = 0):
	var u_x = ZONA_SIGURANTA + offset_x
	var u_y = NIVEL_PODEA
	while u_x < (offset_x + lungime) - ZONA_SIGURANTA - 10:
		var dist_x = randi_range(5, 8)
		var inalt = clamp(u_y + randi_range(-2, 2), NIVEL_PODEA - 6, NIVEL_PODEA - 3)
		var lung_plat = randi_range(3, 6)
		for i in range(lung_plat):
			var pos_x = u_x + dist_x + i
			if pos_x < (offset_x + lungime) - ZONA_SIGURANTA:
				set_cell(Vector2i(pos_x, inalt), ID_IARBA, Vector2i(0, 0))
				if randf() < 0.3:
					set_cell(Vector2i(pos_x, inalt - 1), ID_COIN, Vector2i(0, 0))
				elif randf() < 0.1:
					set_cell(Vector2i(pos_x, inalt - 1), ID_CIUPERCA, Vector2i(0, 0))
		if randf() < 0.2:
			var sol_x = u_x + dist_x / 2
			_spawn_box(sol_x, NIVEL_PODEA - 1)
		u_x += dist_x + lung_plat
		u_y = inalt
	
	# GENERARE USA (O singură dată la finalul nivelului)
	var usa_x = offset_x + lungime - 20 # Poziționată spre finalul zonei de siguranță
	set_cell(Vector2i(usa_x, NIVEL_PODEA - 1), ID_USA, Vector2i(0, 0))
	set_cell(Vector2i(usa_x - 1, NIVEL_PODEA - 1), ID_SEMN_STANGA, Vector2i(0, 0))
	set_cell(Vector2i(usa_x + 1, NIVEL_PODEA - 1), ID_SEMN_DREAPTA, Vector2i(0, 0))
	# AICI salvăm poziția globală corect în variabila clasei
	usa_world_pos = to_global(map_to_local(Vector2i(usa_x, NIVEL_PODEA - 1)))

func _spawn_box(tile_x: int, tile_y: int):
	var box = BOX_SCENE.instantiate()
	var world_pos = map_to_local(Vector2i(tile_x, tile_y))
	world_pos.y -= tile_set.tile_size.y / 2.0
	box.global_position = to_global(world_pos)
	get_parent().call_deferred("add_child", box)
	
	
	
	
	
	
	
	
	
	# Configurații clonare
const CLONE_SCENE = preload("res://Clone.tscn")
var is_recording: bool = false
var recording_data: Array = []

func _physics_process(delta: float) -> void:
	# Logica ta existentă de mișcare aici...
	# handle_movement()
	
	# Gestionare Înregistrare (Tasta C)
	if Input.is_action_just_pressed("record"):
		_toggle_recording()

	# Gestionare Execuție (Tasta E)
	if Input.is_action_just_pressed("execute"):
		_spawn_clone()

	# Înregistrarea propriu-zisă
	if is_recording:
		_record_frame()

func _toggle_recording() -> void:
	is_recording = !is_recording
	if is_recording:
		recording_data.clear()
		modulate = Color(1.5, 0.5, 0.5) # Feedback vizual (roșiatic)
		print("Înregistrare pornită...")
	else:
		modulate = Color(1, 1, 1) # Revenire la normal
		print("Înregistrare oprită. Cadre salvate: ", recording_data.size())

func _record_frame() -> void:
	var frame = {
		"pos": global_position,
		"flip": $Sprite2D.flip_h,
		"anim": $AnimationPlayer.current_animation if $AnimationPlayer.is_playing() else ""
	}
	recording_data.append(frame)

func _spawn_clone() -> void:
	if recording_data.is_empty():
		print("Nu există date înregistrate!")
		return
		
	var clone = CLONE_SCENE.instantiate()
	clone.playback_data = recording_data.duplicate()
	# Adăugăm clona în părintele player-ului (Level) pentru a fi independentă
	get_parent().add_child(clone)
