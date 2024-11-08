extends Window

@onready var music_slider = $VBoxContainer/HBoxContainer/MusicVolumeSlider
@onready var sfx_slider = $VBoxContainer/HBoxContainer2/SFXVolumeSlider
@onready var antialiasing_option = $VBoxContainer/HBoxContainer3/AntialiasingOption 
@onready var music_player = $"../../MusicPlayer"
@onready var option_window = $"."
@onready var blur_overlay = $"../BlurOverlay"

func _ready():
	# Configurar los sliders con valores iniciales
	music_slider.min_value = 0
	music_slider.max_value = 100
	music_slider.value = 50  # Valor inicial del volumen de la música

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
	GameConfig.music_volume = music_slider.value
	option_window.hide()
	blur_overlay.visible = false
