# ===============================
# Nombre del Script: main_menu.gd
# Desarrollador: Carlos Alcaraz Benítez
# Fecha de Creación: 06 de Noviembre de 2024
# Descripción: Este script maneja la lógica de la pantalla de menú principal,
# Se muestran imagenes aleatoriamente cada vez que se carga la escena
# Ventanas emergentes para controlar iniciar partida, opciones, modo de juego y salir.
# He creado un shader para que cuando se activen las ventanas emergentes modales
# el fondo del menú se ponga borroso.
# ===============================
# Listado de funciones
#	_ready(): cargar texturas y opciones de usuario al iniciar
# 	get_random_texture_index() -> int: Obtiene una imagen aleatoria teniendo en cuenta la última textura que se cargó para no repetir
#	save_last_texture_index(): Guarda la imagen para saber cúal ha sido la ultima utilizada
#	load_last_texture_index(): Carga la imagen última utilizada
# 	load_config(): Función para cargar la configuración desde un archivo con solo dos líneas Por ahora guarda la información de volumen de música y sfx.
#	_on_quit_button_pressed(): Señal de boton salir presionada
#	_on_new_game_button_pressed(): Señal de boton nueva partida presionada
#	close_mode_selection_window():  Función para cerrar la ventana modo selección
#	close_option_window(): Función para cerrar la ventana de opciones
#	_on_strategy_button_pressed(): Señal botón estrategia presionado
#	_on_intuition_button_pressed(): Señal botón intuición presionado	
#	_on_ok_button_pressed(): Señal ok en ventana modal salir presionado. Sale del juego
#	_on_cancel_button_pressed(): Señal cancel en ventana modal salir presionado. Cancela salir.
#	_on_bg_card_strategy_texture_button_pressed(): Señal presionar en imagen carga estrategia presionada
#	_on_bg_card_intuition_texture_button_pressed(): Señal presionar en imagen carga intución presionada
#	_on_options_button_pressed():  Señal boton opciones presionada
#	_on_new_game_button_mouse_entered(): Funciones señal mouse entered presionada para reproducir beep
#		_on_load_game_button_mouse_entered():
#		_on_options_button_mouse_entered():
#		_on_quit_button_mouse_entered():
#		_on_ok_button_mouse_entered():
#		_on_cancel_button_mouse_entered():
#		_on_save_option_button_mouse_entered():
#		_on_cancel_option_button_mouse_entered():
#	play_beep_sound(): Función play sonido beep
# ===============================

extends Control

# Referencias a los nodos de la escena
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
# Rutal del archivo txt donde se almacenan los datos de la última textura
const LAST_TEXTURE = "user://last_texture_index.txt"
# Ruta del archivo JSON donde se almacenan los datos de usuario
const USER_DATA_FILE := "user://users.json"
# Ruta del arcchivo JSON donde se almacenan los datos de configuración del juego
const CONFIG_FILE := "user://game_config.cfg"

# Variables de volumen
var volume = {
	"music": 0.0,
	"sfx": 0.0
}

var last_texture_index = -1  # Índice de la última textura seleccionada


func _ready():
	# Carga la configuración de las opciones guardadas en users
	load_config()
	# Carga el volumen del juego
	
	var volume_db = (-80 +(volume["music"] / 100) * 80)
	#var volume_db = lerp(-80, 0, volume["music"] / 100.0)
	music_player.volume_db = volume_db
	volume_db = lerp(-80, 0, volume["sfx"] / 100.0)
	beep_audio_stream_player.volume_db = volume_db
	#Posiciones y tamaño de las ventanas modales
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
	
	# Configura el tamaño fijo de las imagenes aleatorias
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
# Por ahora guarda la información de volumen de música y sfx.
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

# Señal de boton presionada ???
func _on_button_pressed():
	get_tree().change_scene_to_file("res://scenes/LoginScreen.tscn")

# Señal de boton salir presionada
func _on_quit_button_pressed():
	# Mostrar el desenfoque en el fondo
	blur_overlay.visible = true
	# Mostrar el panel de selección de modo	
	exit_window.show()
	
# Señal de boton nueva partida presionada
func _on_new_game_button_pressed():
	# Mostrar el desenfoque en el fondo
	blur_overlay.visible = true
	# Mostrar el panel de selección de modo	
	mode_selection_window.show()

# Función para cerrar la ventana modo selección
func close_mode_selection_window():
	# Ocultar la ventana y el desenfoque del fondo
	mode_selection_window.hide()
	blur_overlay.visible = false

# Función para cerrar la ventana de opciones
func close_option_window():
	# Ocultar la ventana y el desenfoque del fondo
	option_window.hide()
	blur_overlay.visible = false

# Señal botón estrategia presionado
func _on_strategy_button_pressed():
	GameConfig.game_mode = "Estrategia"
	close_mode_selection_window()
	await get_tree().create_timer(0.3).timeout
	get_tree().change_scene_to_file("res://scenes/LoadingGame.tscn")

# Señal botón intuición presionado	
func _on_intuition_button_pressed():
	GameConfig.game_mode = "Intuición"
	close_mode_selection_window()
	await get_tree().create_timer(0.3).timeout
	get_tree().change_scene_to_file("res://scenes/LoadingGame.tscn")

# Señal ok en ventana modal salir presionado. Sale del juego
func _on_ok_button_pressed():
	get_tree().quit()


# Señal cancel en ventana modal salir presionado. Cancela salir.
func _on_cancel_button_pressed():
	exit_window.hide()
	blur_overlay.visible = false


# Señal presionar en imagen carga estrategia presionada
func _on_bg_card_strategy_texture_button_pressed():
	_on_strategy_button_pressed()

# Señal presionar en imagen carga intución presionada
func _on_bg_card_intuition_texture_button_pressed():
	_on_intuition_button_pressed()

# Señal boton opciones presionada
func _on_options_button_pressed():
		# Mostrar el desenfoque en el fondo
	blur_overlay.visible = true
	# Mostrar el panel de selección de modo	
	option_window.show()

# Funciones señal mouse entered presionada para reproducir beep
func _on_new_game_button_mouse_entered():
	play_beep_sound()

func _on_load_game_button_mouse_entered():
	play_beep_sound()

func _on_options_button_mouse_entered():
	play_beep_sound()

func _on_quit_button_mouse_entered():
	play_beep_sound()
	
func _on_ok_button_mouse_entered():
	play_beep_sound()

func _on_cancel_button_mouse_entered():
	play_beep_sound()

func _on_save_option_button_mouse_entered():
	play_beep_sound()

func _on_cancel_option_button_mouse_entered():
	play_beep_sound()

# Función play sonido beep
func play_beep_sound():
	if beep_audio_stream_player.playing:
		beep_audio_stream_player.stop()
	beep_audio_stream_player.play()


func _on_load_game_button_pressed():
	await get_tree().create_timer(0.3).timeout
	get_tree().change_scene_to_file("res://scenes/LoadGame.tscn")
