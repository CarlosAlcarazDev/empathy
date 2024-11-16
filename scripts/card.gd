# ===============================
# Nombre del Script: card.gd
# Desarrollador: Carlos Alcaraz Benítez
# Fecha de Creación: 09 de Noviembre de 2024
# Descripción: Este script maneja la lógica de las cartas
# Desechado por no poder posicionar las imagenes donde quiero cuando se amplian
extends Control

@export var card_frame: TextureRect
@export var card_image = TextureRect
@export var title_card_label: Label
@export var number_card_label: Label
@export var type_card_label: Label
@export var description_card_label: Label

## Posición original de la carta
#var original_position: Vector2
#
#
## Definimos las escalas deseadas
#var NORMAL_SCALE = Vector2()
#const HOVER_SCALE = Vector2(0.20, 0.20)
#const TWEEN_DURATION = 0.2  # Duración de la transición en segundos
#
#func _ready():
	#NORMAL_SCALE = scale
	#original_position = position
#
		#
	## Conectar las señales de entrada y salida del ratón usando `Callable`
	#connect("mouse_entered", Callable(self, "_on_mouse_entered"))
	#connect("mouse_exited", Callable(self, "_on_mouse_exited"))
#
## Método llamado cuando el ratón entra en el área de la carta
#func _on_mouse_entered():
	#print("entrando en imagen")
	## Calcula la nueva posición para "elevar" la tarjeta
	#var hover_position = original_position - Vector2(0, size.y * (HOVER_SCALE.y - NORMAL_SCALE.y)*1.5)
	#position = hover_position
	#scale = HOVER_SCALE
	#
#
#
## Método llamado cuando el ratón sale del área de la carta
#func _on_mouse_exited():
	#print("saliendo de la imagen")
#
	#scale = NORMAL_SCALE
	#position = original_position

func set_card_data(data):
	number_card_label.text = str(data)
