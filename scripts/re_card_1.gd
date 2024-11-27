# ===============================
# Nombre del Script: re_card_1.gd
# Desarrollador: Carlos Alcaraz Benítez
# Fecha de Creación: 14 de Noviembre de 2024
# Descripción: Este script maneja la lógica de la carta re posicion 1
# Ampliar la carta al pasar por encima de ella
# Si doble click sobre la carta, carta seleccionada y colocada en posicion seleccionada (minimizada).
# Emite señal con la id de la carta seleccionada
# ===============================
# Listado de funciones
#	_ready(): Función para conectar las señales de entrar y salir el mouse y doble click, define escala, posicion e indice
#	_on_mouse_entered(): Señal mouse ha entrado. Escala la imagen y la coloca encima de la actual
#	_on_mouse_exited(): Señal mouse ha salido. Restaura la escala y posición originales solo si la carta no ha sido movida
#	on_gui_input(event): Señal doble click izquierdo raton 
#	move_to_original_position(): Función para mover la carta de vuelta a su posición original
extends Control
@onready var beep_audio_stream_player = $"../../../UI/BeepAudioStreamPlayer"

# Señal que se emitirá cuando la carta sea seleccionada. Enviará el id de la carta
signal card_chosen_re(card_id)
# Referencias a los nodos de la escena
@onready var re_card_1 = $"."
@onready var number_card_label = $NumberCardLabel
# Define las constantes escalas de la carta
const NORMAL_SCALE = Vector2(0.13, 0.13)
const HOVER_SCALE = Vector2(0.27, 0.27)
const TARGET_SCALE = Vector2(0.1, 0.1)
# Variables para guardar la posicion original de la carta
var _position = position
# Variable para almacenar el z_index original
var original_z_index = 0  
# Define la posición a la que se moverá la carta
const TARGET_POSITION = Vector2(601, 494)  
const ORIGINAL_POSITION = Vector2(354.7, 804)
# Bandera para verificar si la carta ha sido movida
var is_moved = false  

# Función para conectar las señales de entrar y salir el mouse y doble click, define escala, posicion e indice
func _ready():
	connect("mouse_entered", Callable(self, "_on_mouse_entered"))
	connect("mouse_exited", Callable(self, "_on_mouse_exited"))
	connect("gui_input", Callable(self, "on_gui_input"))

	scale = NORMAL_SCALE
	position = ORIGINAL_POSITION
	# Almacena el z_index original para restaurarlo después del arrastre
	original_z_index = z_index

# Señal mouse ha entrado. Escala la imagen y la coloca encima de la actual
func _on_mouse_entered():
	if not is_moved:
		position.y = _position.y - 292
		scale = HOVER_SCALE
		z_index = 10

# Señal mouse ha salido. Restaura la escala y posición originales solo si la carta no ha sido movida
func _on_mouse_exited():
	if not is_moved:
		scale = NORMAL_SCALE
		position = ORIGINAL_POSITION
		z_index = original_z_index

# Señal doble click izquierdo raton
func on_gui_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.double_click:
		# Si hay una carta en TARGET_POSITION, restáurala a su posición original
		if GlobalData.current_card_in_target_positionRE != null and GlobalData.current_card_in_target_positionRE != self:
			GlobalData.current_card_in_target_positionRE.move_to_original_position()
		play_beep_sound()
		# Mueve esta carta a TARGET_POSITION
		is_moved = true  # Marca la carta como movida para que no vuelva al estado original
		position = TARGET_POSITION
		scale = TARGET_SCALE
		z_index = 4
		GlobalData.current_card_in_target_positionRE = self  # Actualiza la carta actual como la que está en TARGET_POSITION
		print("Carta movida a TARGET_POSITION: ", self)
		GlobalData.id_current_card_in_target_positionRE = number_card_label.text
		# Emitir la señal indicando que la carta ha sido seleccionada y envia id de la carta seleccionada
		emit_signal("card_chosen_re", number_card_label.text)

# Función para mover la carta de vuelta a su posición original
func move_to_original_position():
	# Método para mover esta carta de vuelta a su posición original
	position = ORIGINAL_POSITION
	scale = NORMAL_SCALE
	z_index = original_z_index
	is_moved = false
	# Limpia current_card_in_target_position si esta carta está en la posición objetivo
	if GlobalData.current_card_in_target_positionRE == self:
		GlobalData.current_card_in_target_positionRE = null
	print("Carta devuelta a la posición original: ", self)

# Función para reproducir el sonido
func play_beep_sound():
	# Cargar el archivo de audio en tiempo de ejecución
	var audio_stream = load("res://assets/audio/sfx/seleccionar_carta.ogg")
	# Asignar el audio al AudioStreamPlayer
	beep_audio_stream_player.stream = audio_stream
	if beep_audio_stream_player.playing:
		beep_audio_stream_player.stop()
	beep_audio_stream_player.play()
