extends Window

@onready var music_slider = $VBoxContainer/HBoxContainer/MusicVolumeSlider
@onready var sfx_slider = $VBoxContainer/HBoxContainer2/SFXVolumeSlider
@onready var antialiasing_option = $VBoxContainer/HBoxContainer3/AntialiasingOption
@onready var music_player = $"../../MusicPlayer"
@onready var option_window = $"." 
@onready var blur_overlay = $"../BlurOverlay"
@onready var beep_audio_stream_player = $"../../BeepAudioStreamPlayer"

const CONFIG_FILE := "user://game_config.cfg"

var volume = {
	"music": 0.0,
	"sfx": 0.0
}
var antialiasing_selected = 0

func _ready():
	load_config()  # Primero cargamos la configuración
	
	# Configurar los sliders con valores iniciales
	music_slider.min_value = 0
	music_slider.max_value = 100
	music_slider.value = volume["music"]  # Valor inicial del volumen de la música
	GameConfig.music_volume = music_slider.value  # Guarda el valor del slider en el singleton por si se clica en cancelar y volver al valor original

	sfx_slider.min_value = 0
	sfx_slider.max_value = 100
	print("Volume sfx "  + str(volume["sfx"]))
	sfx_slider.value = volume["sfx"]  # Valor inicial del volumen de los efectos SFX
	GameConfig.sfx_volume = sfx_slider.value  # Guarda el valor del slider en el singleton por si se clica en cancelar y volver al valor original

	# Configurar el OptionButton con opciones de antialiasing
	antialiasing_option.add_item("Desactivado", 0)  # Índice 0
	antialiasing_option.add_item("2x", 2)           # Índice 1
	antialiasing_option.add_item("4x", 4)           # Índice 2
	antialiasing_option.add_item("8x", 8)           # Índice 3

	# Reflejar el valor cargado de antialiasing
	antialiasing_option.selected = antialiasing_selected  # Debe aplicarse después de cargar la configuración
	GameConfig.temp_antialiasing_selected = antialiasing_option.selected
	
	
	# Conectar las señales de los sliders y OptionButton
	music_slider.value_changed.connect(_on_music_volume_changed)
	sfx_slider.value_changed.connect(_on_sfx_volume_changed)
	antialiasing_option.item_selected.connect(_on_antialiasing_selected)

# Funciones para manejar los cambios
func _on_music_volume_changed(value):
	# Convertir el valor del slider (0 a 100) a decibelios (-80 a 0)
	var volume_db = lerp(-80, 0, value / 100.0)
	music_player.volume_db = volume_db

func _on_sfx_volume_changed(value):
	var volume_db = lerp(-80, 0, value / 100.0)
	beep_audio_stream_player.volume_db = volume_db
	play_beep_sound()
	print("Nuevo volumen de SFX:", value)
	# Aquí podrías actualizar el volumen de los efectos de sonido en tu AudioStream

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

func _on_save_option_button_pressed():
	save_config()

	GameConfig.music_volume = music_slider.value
	GameConfig.sfx_volume = sfx_slider.value
	GameConfig.antialiasing_selected = antialiasing_option.selected
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
		file.close()
		print("Configuración guardada en user://game_config.cfg")

# Función para cargar la configuración desde un archivo con solo tres líneas
func load_config():
	if FileAccess.file_exists(CONFIG_FILE):
		var file = FileAccess.open(CONFIG_FILE, FileAccess.READ)
		if file:
			var music_line = file.get_line().strip_edges()  # Leer la primera línea (música)
			var sfx_line = file.get_line().strip_edges()    # Leer la segunda línea (sfx)
			var antialiasing_line = file.get_line().strip_edges()  # Leer la tercera línea (antialiasing)

			if music_line.is_valid_float():
				volume["music"] = music_line.to_float()

			if sfx_line.is_valid_float():
				volume["sfx"] = sfx_line.to_float()

			if antialiasing_line.is_valid_int():
				antialiasing_selected = antialiasing_line.to_int()

			file.close()
			print("Configuración cargada desde user://game_config.cfg")
		else:
			print("Error al leer el archivo de configuración")
	else:
		print("No se encontró un archivo de configuración, usando valores predeterminados")

func _on_cancel_option_button_pressed():
	music_slider.value = GameConfig.music_volume
	sfx_slider.value = GameConfig.sfx_volume
	antialiasing_option.selected = GameConfig.temp_antialiasing_selected  # Restaurar el valor original del antialiasing
	option_window.hide()
	blur_overlay.visible = false
	
func play_beep_sound():
	if beep_audio_stream_player.playing:
		beep_audio_stream_player.stop()
	beep_audio_stream_player.play()


func _on_statistics_button_pressed():
	GameConfig.music_volume = music_slider.value
	get_tree().change_scene_to_file("res://scenes/StatisticsScreen.tscn")
	
func _on_credits_button_pressed():
	
	get_tree().change_scene_to_file("res://scenes/CreditsScreen.tscn")
