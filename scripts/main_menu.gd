# ===============================
# Nombre del Script: MainMenu.gd
# Desarrollador: Carlos Alcaraz Benítez
# Fecha de Creación: 06 de Noviembre de 2024
# Descripción: Este script maneja la lógica de la pantalla de menú principal,
# # Se muestran imagenes aleatoriamente cada vez que se carga la escena
# ===============================

extends Control


@onready var user_label = $UserLabel
@onready var id_label = $IDLabel
@onready var audio_stream_player_2d = $AudioStreamPlayer2D

@onready var texture_rect = $TextureRect
@onready var confirmation_dialog = $ConfirmationDialog


# Precarga las texturas que se mostrarán aleatoriamente
const TEXTURES = [
	preload("res://assets/ui/backgrounds/login_bg_1.png"),
	preload("res://assets/ui/backgrounds/login_bg_2.png"),
	preload("res://assets/ui/backgrounds/login_bg_3.png"),
	preload("res://assets/ui/backgrounds/login_bg_4.png")
]
const LAST_TEXTURE = "user://last_texture_index.txt"
# Ruta del archivo JSON donde se almacenan los datos de usuario
const USER_DATA_FILE := "user://users.json"


var last_texture_index = -1  # Índice de la última textura seleccionada


func _ready():
	id_label.text = "ID: " + str(GlobalData.id)
	user_label.text = "Usuario: " + GlobalData.user

	
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
	#print("last_texture_index, new_index:", last_texture_index, new_index)
	while new_index == last_texture_index:
		new_index = randi() % TEXTURES.size()
		#print("last_texture_index, new_index:", last_texture_index, new_index)
	return new_index

# Guarda la imagen para saber cúal ha sido la ultima utilizada
func save_last_texture_index():
	var file = FileAccess.open(LAST_TEXTURE, FileAccess.ModeFlags.WRITE)
	if file:
		file.store_var(last_texture_index)
		file.close()

# Carga la imagen última utilizada
func load_last_texture_index():
	var file = FileAccess.open(LAST_TEXTURE, FileAccess.ModeFlags.READ)
	if file:
		if FileAccess.file_exists(LAST_TEXTURE):
			last_texture_index = file.get_var()
			file.close()
		else:
			last_texture_index = -1


func _on_button_pressed():
	get_tree().change_scene_to_file("res://scenes/LoginScreen.tscn")



func _on_confirmation_dialog_confirmed():
	get_tree().quit()


func _on_quit_button_pressed():
	confirmation_dialog.popup()  # Muestra la ventana emergente


func _on_confirmation_dialog_canceled():
	pass # Replace with function body.


func _on_new_game_button_pressed():
	get_tree().change_scene_to_file("res://scenes/NewGame.tscn")
