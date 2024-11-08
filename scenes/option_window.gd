extends Window

@onready var music_slider = $VBoxContainer/HBoxContainer/MusicVolumeSlider
@onready var sfx_slider = $VBoxContainer/HBoxContainer2/SFXVolumeSlider
@onready var antialiasing_option = $VBoxContainer/HBoxContainer3/AntialiasingOption 
@onready var music_player = $"../../MusicPlayer"
@onready var option_window = $"."
@onready var blur_overlay = $"../BlurOverlay"

const CONFIG_FILE := "user://game_config.cfg"

var volume = {
	"music": 0.0,
	"sfx": 0.0
}


func _ready():
	load_config()
	# Configurar los sliders con valores iniciales
	music_slider.min_value = 0
	music_slider.max_value = 100
	print("volume music en option " + str(volume["music"]))
	music_slider.value = ((volume["music"] - (-80)) / (0 - (-80))) * 100  # Valor inicial del volumen de la música

	sfx_slider.min_value = 0
	sfx_slider.max_value = 100
	sfx_slider.value = 50  # Valor inicial del volumen de los efectos SFX

	# Configurar el OptionButton con opciones de antialiasing
	antialiasing_option.add_item("Desactivado", 0)
	antialiasing_option.add_item("2x", 2)
	antialiasing_option.add_item("4x", 4)
	antialiasing_option.add_item("8x", 8)
	antialiasing_option.selected = 0  # Selección predeterminada (Desactivado)

	# Conectar las señales de los sliders y OptionButton
	music_slider.value_changed.connect(_on_music_volume_changed)
	sfx_slider.value_changed.connect(_on_sfx_volume_changed)
	antialiasing_option.item_selected.connect(_on_antialiasing_selected)

# Funciones para manejar los cambios
func _on_music_volume_changed(value):
	print("Nuevo volumen de música:", value)
	# Convertir el valor del slider (0 a 100) a decibelios (-80 a 0)
	var volume_db = lerp(-80, 0, value / 100.0)
	music_player.volume_db = volume_db
	print("Nuevo volumen de música:", volume_db)
	
func _on_sfx_volume_changed(value):
	print("Nuevo volumen de SFX:", value)
	# Aquí podrías actualizar el volumen de los efectos de sonido en tu AudioStream

func _on_antialiasing_selected(id):
	match id:
		0:
			print("Antialiasing desactivado")
			# Aplica la configuración para desactivar antialiasing
		2:
			print("Antialiasing 2x activado")
			# Aplica la configuración de 2x antialiasing
		4:
			print("Antialiasing 4x activado")
			# Aplica la configuración de 4x antialiasing
		8:
			print("Antialiasing 8x activado")
			# Aplica la configuración de 8x antialiasing


func _on_save_option_button_pressed():
	save_config()
	GameConfig.music_volume = music_slider.value
	option_window.hide()
	blur_overlay.visible = false



# Función para guardar la configuración en un archivo
func save_config():
	var file = FileAccess.open("user://game_config.cfg", FileAccess.WRITE)
	if file:
		print(str(music_player.volume_db))
		file.store_line(str(music_player.volume_db))  # Guardar el volumen de música en la primera línea
		file.store_line("sfx")    # Guardar el volumen de SFX en la segunda línea
		file.close()
		print("Configuración guardada en user://game_config.cfg")


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
