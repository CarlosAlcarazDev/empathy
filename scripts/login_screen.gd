# ===============================
# Nombre del Script: LoginScreen.gd
# Desarrollador: Carlos Alcaraz Benítez
# Fecha de Creación: 04 de Noviembre de 2024
# Descripción: Este script maneja la lógica de la pantalla de login del juego,
# incluyendo el inicio y la creación de un nuevo usuario.
# ===============================
extends Control

@onready var audio_stream_player = $CreateButton/AudioStreamPlayer


# Precarga las texturas que se mostrarán aleatoriamente
const TEXTURES = [
	preload("res://assets/ui/backgrounds/login_bg_1.png"),
	preload("res://assets/ui/backgrounds/login_bg_2.png"),
	preload("res://assets/ui/backgrounds/login_bg_3.png"),
	preload("res://assets/ui/backgrounds/login_bg_4.png")
]

@onready var texture_rect = $TextureRect

var last_texture_index = -1  # Índice de la última textura seleccionada
const SAVE_PATH = "res://save/last_texture_index.save.txt"

func _ready():
	randomize()  # Inicializa el generador de números aleatorios
	
	# Carga el último índice de textura desde el archivo
	load_last_texture_index()
	
	# Selecciona un índice aleatorio de la lista que no sea igual al último seleccionado
	var random_texture_index = get_random_texture_index()
	
	# Asigna la textura aleatoria al TextureRect
	texture_rect.texture = TEXTURES[random_texture_index]
	
	# Actualiza el índice de la última textura seleccionada
	last_texture_index = random_texture_index
	
	# Guarda el nuevo índice de textura en el archivo
	save_last_texture_index()
	
	# Configura el tamaño fijo
	texture_rect.size_flags_horizontal = Control.SIZE_SHRINK_END - 100
	texture_rect.size_flags_vertical = Control.SIZE_SHRINK_CENTER - 100

# Obtiene una imagen aleatoria teniendo en cuenta la última textura que se cargó para no repetir
func get_random_texture_index() -> int:
	var new_index = randi() % TEXTURES.size()
	print("last_texture_index, new_index:", last_texture_index, new_index)
	while new_index == last_texture_index:
		new_index = randi() % TEXTURES.size()
		print("last_texture_index, new_index:", last_texture_index, new_index)
	return new_index

# Guarda la imagen para saber cúal ha sido la ultima utilizada
func save_last_texture_index():
	var file = FileAccess.open(SAVE_PATH, FileAccess.ModeFlags.WRITE)
	if file:
		file.store_var(last_texture_index)
		file.close()

# Carga la imagen última utilizada
func load_last_texture_index():
	var file = FileAccess.open(SAVE_PATH, FileAccess.ModeFlags.READ)
	if file:
		if FileAccess.file_exists(SAVE_PATH):
			last_texture_index = file.get_var()
			file.close()
		else:
			last_texture_index = -1

# Señal botón salir presionada
func _on_quit_button_pressed():
	get_tree().quit(0)


func _on_login_button_pressed():
	audio_stream_player.playing = true
	


func _on_create_button_pressed():
	get_tree().change_scene_to_file("res://scenes/CreateUser.tscn")


func _on_audio_stream_player_finished():
	get_tree().change_scene_to_file("res://scenes/CreateUser.tscn")
