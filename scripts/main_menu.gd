# ===============================
# Nombre del Script: MainMenu.gd
# Desarrollador: Carlos Alcaraz Benítez
# Fecha de Creación: 06 de Noviembre de 2024
# Descripción: Este script maneja la lógica de la pantalla de menú principal,
# # Se muestran imagenes aleatoriamente cada vez que se carga la escena
# Ventanas emergentes para controlar iniciar partida y salir.
# He creado un shader para que cuando se activen las ventanas emergentes de tipo windows
# el fondo del menú se ponga borroso.
# ===============================

extends Control


@onready var user_label = $UserLabel
@onready var id_label = $IDLabel

@onready var music_player = $MusicPlayer

@onready var texture_rect = $TextureRect

@onready var blur_overlay = $Overlay/BlurOverlay
@onready var exit_window = $Overlay/ExitWindow
@onready var mode_selection_window = $Overlay/ModeSelectionWindow
@onready var option_window = $Overlay/OptionWindow
@onready var beep_audio_stream_player = $BeepAudioStreamPlayer

@onready var new_game_button = $VBoxContainer/NewGameButton


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
const CONFIG_FILE := "user://game_config.cfg"

var volume = {
	"music": 0.0,
	"sfx": 0.0
}

var last_texture_index = -1  # Índice de la última textura seleccionada


func _ready():
	# Carga la configuración de las opciones guardadas en //users
	load_config()
	var volume_db = lerp(-80, 0, volume["music"] / 100.0)
	music_player.volume_db = volume_db
	volume_db = lerp(-80, 0, volume["sfx"] / 100.0)
	beep_audio_stream_player.volume_db = volume_db
	id_label.text = "ID: " + str(GlobalData.id)
	user_label.text = "Usuario: " + GlobalData.user
	exit_window.position = Vector2(785,484)
	exit_window.size = Vector2(350,112)
	mode_selection_window.position = Vector2(500,450)
	mode_selection_window.size = Vector2(850,600)
	option_window.position = Vector2(710,500)
	option_window.size = Vector2(500,550)
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



# Función para cargar la configuración desde un archivo con solo dos líneas
func load_config():
	if FileAccess.file_exists(CONFIG_FILE):
		var file = FileAccess.open(CONFIG_FILE, FileAccess.READ)
		if file:
			var music_line = file.get_line().strip_edges()  # Leer la primera línea (música)
			var sfx_line = file.get_line().strip_edges()    # Leer la segunda línea (SFX)
			if music_line.is_valid_float():
				volume["music"] = music_line.to_float()
			if sfx_line.is_valid_float():
				volume["sfx"] = sfx_line.to_float()
			file.close()
			print("Configuración cargada desde user://game_config.cfg")
		else:
			print("Error al leer el archivo de configuración")
	else:
		print("No se encontró un archivo de configuración, usando valores predeterminados")

func _on_button_pressed():
	get_tree().change_scene_to_file("res://scenes/LoginScreen.tscn")




func _on_quit_button_pressed():
	# Mostrar el desenfoque en el fondo
	blur_overlay.visible = true

	# Mostrar el panel de selección de modo	
	exit_window.show()
	

func _on_new_game_button_pressed():
		# Mostrar el desenfoque en el fondo
	blur_overlay.visible = true

	# Mostrar el panel de selección de modo	
	mode_selection_window.show()

func _on_strategy_button_pressed():
	GameConfig.game_mode = "Estrategia"
	close_mode_selection_window()

func close_mode_selection_window():
	# Ocultar la ventana y el desenfoque del fondo
	mode_selection_window.hide()
	blur_overlay.visible = false

func close_option_window():
	# Ocultar la ventana y el desenfoque del fondo
	option_window.hide()
	blur_overlay.visible = false



func _on_intuition_button_pressed():
	GameConfig.game_mode = "Intuición"
	close_mode_selection_window()


func _on_ok_button_pressed():
	get_tree().quit()



func _on_cancel_button_pressed():
	exit_window.hide()
	blur_overlay.visible = false




func _on_bg_card_strategy_texture_button_pressed():
	print("pressed strategy")
	close_mode_selection_window()


func _on_bg_card_intuition_texture_button_pressed():
	print("pressed intuition")
	close_mode_selection_window()


func _on_options_button_pressed():
		# Mostrar el desenfoque en el fondo
	blur_overlay.visible = true

	# Mostrar el panel de selección de modo	
	option_window.show()


func _on_new_game_button_mouse_entered():
	play_beep_sound()

func _on_load_game_button_mouse_entered():
	play_beep_sound()
	
func _on_options_button_mouse_entered():
	play_beep_sound()

func _on_quit_button_mouse_entered():
	play_beep_sound()

func play_beep_sound():
	if beep_audio_stream_player.playing:
		beep_audio_stream_player.stop()
	beep_audio_stream_player.play()


func _on_ok_button_mouse_entered():
	play_beep_sound()


func _on_cancel_button_mouse_entered():
	play_beep_sound()


func _on_save_option_button_mouse_entered():
	play_beep_sound()


func _on_cancel_option_button_mouse_entered():
	play_beep_sound()


func _on_credits_button_pressed():
	
	get_tree().change_scene_to_file("res://scenes/CreditsScreen.tscn")
