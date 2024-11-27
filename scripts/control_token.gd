
extends Control


@onready var beep_audio_stream_player = $"/root/NewGame/UI/BeepAudioStreamPlayer"

# Define las constantes escalas de la carta
const NORMAL_SCALE = Vector2(0.14, 0.14)
const HOVER_SCALE = Vector2(0.5, 0.5)

# Variables para guardar la posicion original de la carta
var _position = position
# Variable para almacenar el z_index original
var original_z_index = 0  
# Mapeo de texturas a sus respectivos sonidos
var texture_to_audio = {
	"ExclusionSocialToken": "res://assets/audio/sfx/token_exclusión_social.mp3",
	"FisicoToken": "res://assets/audio/sfx/token_físico.mp3",
	"PsicologicoToken": "res://assets/audio/sfx/token_psicológico.mp3",
	"SexualToken": "res://assets/audio/sfx/token_sexual.mp3",
	"VerbalToken": "res://assets/audio/sfx/token_verbal.mp3",
	"CiberbullyingToken": "res://assets/audio/sfx/token_ciberbullying.mp3"
}
# Función para conectar las señales de entrar y salir el mouse y doble click, define escala, posicion e indice
func _ready():
	connect("mouse_entered", Callable(self, "_on_mouse_entered"))
	connect("mouse_exited", Callable(self, "_on_mouse_exited"))

	scale = NORMAL_SCALE

	# Almacena el z_index original para restaurarlo después del arrastre
	original_z_index = z_index

# Señal mouse ha entrado. Escala la imagen y la coloca encima de la actual
func _on_mouse_entered():

	position.y = _position.y - 150
	# Función para reproducir el sonido
# Identifica el sonido correspondiente según la textura
	var texture_name = name  # Nombre del nodo que debe coincidir con la clave en el mapeo
	var audio_path = texture_to_audio.get(texture_name, null)

	if audio_path:
		# Cargar el archivo de audio en tiempo de ejecución
		var audio_stream = load(audio_path)
		# Asignar el audio al AudioStreamPlayer
		beep_audio_stream_player.stream = audio_stream
		if beep_audio_stream_player.playing:
			beep_audio_stream_player.stop()
		beep_audio_stream_player.play()
	else:
		print("No se encontró un sonido para la textura:", texture_name)
	
	scale = HOVER_SCALE
	z_index = 10

# Señal mouse ha salido. Restaura la escala y posición originales solo si la carta no ha sido movida
func _on_mouse_exited():
	scale = NORMAL_SCALE
	z_index = original_z_index
	position = _position
