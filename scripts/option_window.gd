# ===============================
# Nombre del Script: option_window.gd
# Desarrollador: Carlos Alcaraz Benítez
# Fecha de Creación: 07 de Noviembre de 2024
# Descripción: Este script maneja la lógica del modal de opciones
# Volumen música, sfx.
# Antialiasing
# Mostrar estadísticas y créditos
# ===============================
# Listado de funciones
#	_ready(): cargar texturas y opciones de usuario al iniciar
#	_on_music_volume_changed(value): Funciones para manejar los cambios en las opciones
#	_on_sfx_volume_changed(value): Funciones para manejar los cambios en las opciones
#	_on_antialiasing_selected(id): Funciones para manejar los cambios en las opciones
#	func _on_save_option_button_pressed(): Señal boton guardar presionado
#	save_config(): Función para guardar la configuración en un archivo
#	load_config():  Función para cargar la configuración desde un archivo con solo tres líneas
#	_on_cancel_option_button_pressed(): Señal botón cancelado presionado
#	play_beep_sound(): Función para reproducir el sonido
#	_on_statistics_button_pressed(): Señal boton estadísticas presionado
#	_on_credits_button_pressed(): Señal boton creditos presionado
# ===============================
extends Window

# Referencias a los nodos de la escena
@onready var music_slider = $VBoxContainer/HBoxContainer/MusicVolumeSlider
@onready var sfx_slider = $VBoxContainer/HBoxContainer2/SFXVolumeSlider
@onready var antialiasing_option = $VBoxContainer/HBoxContainer3/AntialiasingOption
@onready var ia_difficulty_option = $VBoxContainer/HBoxContainer5/IADifficultyOption

@onready var music_player = $"../../MusicPlayer"
@onready var option_window = $"." 
@onready var blur_overlay = $"../BlurOverlay"
@onready var beep_audio_stream_player = $"../../BeepAudioStreamPlayer"

const DEFAULT_CONFIG = {
	"music_volume": 50, 	# Volumen predeterminado de la música
	"sfx_volume": 50,		# Volumen predeterminado para SFX
	"antialiasing": 0,		# Antialiasing desactivado
	"ia_difficulty": 0		# Dificultad predeterminada: Estudiante	
}


# Ruta del archivo JSON donde se almacenan los datos de usuario
const CONFIG_FILE := "user://game_config.cfg"

# Variables para manejar el volumen y el antialiasing
var volume = {
	"music": 0.0,
	"sfx": 0.0
}
var antialiasing_selected = 0
var iadifficulty_selected = 0

# Cargar configuración juego al iniciar
func _ready():
	load_config()  # Primero carga la configuración
	
	# Configura los sliders con valores iniciales
	music_slider.min_value = 0
	music_slider.max_value = 100
	music_slider.value = volume["music"]  # Valor inicial del volumen de la música
	GameConfig.music_volume = music_slider.value  # Guarda el valor del slider en el singleton por si se clica en cancelar y volver al valor original

	sfx_slider.min_value = 0
	sfx_slider.max_value = 100
	print("Volume sfx "  + str(volume["sfx"]))
	sfx_slider.value = volume["sfx"]  # Valor inicial del volumen de los efectos SFX
	GameConfig.sfx_volume = sfx_slider.value  # Guarda el valor del slider en el singleton por si se clica en cancelar y volver al valor original

	# Configura el OptionButton con opciones de antialiasing
	antialiasing_option.add_item("Desactivado", 0)  # Índice 0
	antialiasing_option.add_item("2x", 2)           # Índice 1
	antialiasing_option.add_item("4x", 4)           # Índice 2
	antialiasing_option.add_item("8x", 8)           # Índice 3
	GameConfig.antialiasing_selected = antialiasing_option.selected

	# Configura el OptionButton con opciones de dificultad de la IA
	#ia_difficulty_option.add_item("Principiante - Estudiante", GameConfig.Difficulty.ESTUDIANTE) #Índice 0
	#ia_difficulty_option.add_item("Intermedio - Profesor", GameConfig.Difficulty.PROFESOR) #Índice 1
	#ia_difficulty_option.add_item("Experto - Psicólogo", GameConfig.Difficulty.PSICOLOGO) #Índice 2
	ia_difficulty_option.add_item("Principiante - Estudiante", 0) #Índice 0
	ia_difficulty_option.add_item("Intermedio - Profesor", 1) #Índice 1
	ia_difficulty_option.add_item("Experto - Psicólogo", 2) #Índice 2
		# Refleja el valor cargado de dificultad
	print("Valor cargado de dificultad IA antes de asignar:", GameConfig.ia_difficulty)
	ia_difficulty_option.selected = GameConfig.ia_difficulty
	print("Valor seleccionado del OptionButton:", ia_difficulty_option.selected)

	# Refleja el valor cargado de antialiasing
	antialiasing_option.selected = antialiasing_selected  # Debe aplicarse después de cargar la configuración
	ia_difficulty_option.selected = iadifficulty_selected
	ia_difficulty_option.selected = GameConfig.ia_difficulty
	
	# Conectar las señales de los sliders y OptionButton
	music_slider.value_changed.connect(_on_music_volume_changed)
	sfx_slider.value_changed.connect(_on_sfx_volume_changed)
	antialiasing_option.item_selected.connect(_on_antialiasing_selected)
	ia_difficulty_option.item_selected.connect(_on_ia_difficulty_selected)

# Funciones para manejar los cambios en las opciones
func _on_music_volume_changed(value):
	GameConfig.music_volume = value  # Actualiza el autoload directamente
	# Convertir el valor del slider (0 a 100) a decibelios (-80 a 0)
	var volume_db = lerp(-80, 0, value / 100.0)
	music_player.volume_db = volume_db

func _on_sfx_volume_changed(value):
	GameConfig.sfx_volume = value
	var volume_db = lerp(-80, 0, value / 100.0)
	beep_audio_stream_player.volume_db = volume_db
	play_beep_sound()
	print("Nuevo volumen de SFX:", value)

func _on_antialiasing_selected(id):
	match id:
		0:
			print("Antialiasing desactivado")
			ProjectSettings.set_setting("rendering/quality/filters/msaa", 0)
			GameConfig.antialiasing_selected = 0
		1:
			print("Antialiasing 2x activado")
			ProjectSettings.set_setting("rendering/quality/filters/msaa", 2)
			GameConfig.antialiasing_selected = 1
		2:
			print("Antialiasing 4x activado")
			ProjectSettings.set_setting("rendering/quality/filters/msaa", 4)
			GameConfig.antialiasing_selected = 2
		3:
			print("Antialiasing 8x activado")
			ProjectSettings.set_setting("rendering/quality/filters/msaa", 8)
			GameConfig.antialiasing_selected = 3
			
func _on_ia_difficulty_selected(id):
	GameConfig.ia_difficulty = id
	print("Nueva dificultad seleccionada:", id)
	
# Señal boton guardar presionado
func _on_save_option_button_pressed():
	# Guarda la configuración en eñ archivo json
	save_config()
	# Guarda la configuración en el singleton
	GameConfig.music_volume = music_slider.value
	GameConfig.sfx_volume = sfx_slider.value
	GameConfig.antialiasing_selected = antialiasing_option.selected
	GameConfig.ia_difficulty = ia_difficulty_option.selected
	# Cerrar la ventana modal de opciones y quitar el efecto borroso
	option_window.hide()
	blur_overlay.visible = false

# Función para guardar la configuración en un archivo
func save_config():
	var file = FileAccess.open(CONFIG_FILE, FileAccess.WRITE)
	if file:
		#file.store_line(str(music_player.volume_db))  # Guardar el volumen de música en la primera línea
		file.store_line(str(music_slider.value))  # Guardar el volumen de música en la primera línea
		file.store_line(str(sfx_slider.value))        # Guardar el volumen de SFX correctamente
		file.store_line(str(antialiasing_option.selected))  # Guardar el índice seleccionado del antialiasing
		#file.store_line(str(GameConfig.ia_difficulty)) # Guardar el índice seleccionado de la dificultad de la ia
		file.store_line(str(ia_difficulty_option.selected)) # Guardar el índice seleccionado de la dificultad de la ia
		
		file.close()
		#print("Configuración guardada en user://game_config.cfg")

# Función para cargar la configuración desde un archivo con solo 4 líneas
func load_config():
	if FileAccess.file_exists(CONFIG_FILE):
		var file = FileAccess.open(CONFIG_FILE, FileAccess.READ)
		if file:
			var music_line = file.get_line().strip_edges()  # Leer la primera línea (música)
			var sfx_line = file.get_line().strip_edges()    # Leer la segunda línea (sfx)
			var antialiasing_line = file.get_line().strip_edges()  # Leer la tercera línea (antialiasing)
			var iadifficulty_line = file.get_line().strip_edges() # Leer la cuarta línea (ia dificultad)
			if music_line.is_valid_float():
				volume["music"] = music_line.to_float()

			if sfx_line.is_valid_float():
				volume["sfx"] = sfx_line.to_float()

			if antialiasing_line.is_valid_int():
				antialiasing_selected = antialiasing_line.to_int()
				
			if iadifficulty_line.is_valid_int():
				iadifficulty_selected = iadifficulty_line.to_int()
				GameConfig.ia_difficulty = iadifficulty_selected  # Asegura persiste				GameConfig.ia_difficulty = GameConfig.Difficulty(iadifficulty_selected)  # Cast explícito
			file.close()
			print("Configuración cargada desde user://game_config.cfg")
		else:
			print("Error al leer el archivo de configuración")
	else:
		print("No se encontró un archivo de configuración, usando valores predeterminados")

# Señal botón cancelado presionado
func _on_cancel_option_button_pressed():
	# Restaurar a los valores predeterminados
	GameConfig.music_volume = DEFAULT_CONFIG["music_volume"]
	GameConfig.sfx_volume = DEFAULT_CONFIG["sfx_volume"]
	GameConfig.antialiasing_selected = DEFAULT_CONFIG["antialiasing"]
	GameConfig.ia_difficulty = DEFAULT_CONFIG["ia_difficulty"]
	music_slider.value = GameConfig.music_volume
	sfx_slider.value = GameConfig.sfx_volume
	antialiasing_option.selected = GameConfig.antialiasing_selected
	ia_difficulty_option.selected = GameConfig.ia_difficulty
	blur_overlay.visible = false

# Función para reproducir el sonido
func play_beep_sound():
	if beep_audio_stream_player.playing:
		beep_audio_stream_player.stop()
	beep_audio_stream_player.play()

# Señal boton estadísticas presionado
func _on_statistics_button_pressed():
	GameConfig.music_volume = music_slider.value
	get_tree().change_scene_to_file("res://scenes/StatisticsScreen.tscn")

# Señal boton creditos presionado
func _on_credits_button_pressed():
	get_tree().change_scene_to_file("res://scenes/CreditsScreen.tscn")
