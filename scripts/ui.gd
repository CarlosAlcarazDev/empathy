# ===============================
# Nombre del Script: ui.gd
# Desarrollador: Carlos Alcaraz Benítez
# Fecha de Creación: 07 de Noviembre de 2024
# Descripción: Este script maneja la lógica de la ui de la partida
# Por ahora boton opciones (superior izquierda). Habilitado para salir.
# ===============================
# Listado de funciones
#	_on_options_texture_button_pressed(): Señal boton presionado en opciones
# ===============================

extends Control

# Referencias a los nodos de la escena
@onready var ready_texture_button = $ReadyTextureButton

@onready var reverse_anverse_toggle_button = $ReverseAnverseToggleButton

# Definimos la señal personalizada
signal reverse_anverse_toggled(showing_reverses: bool)

var showing_reverses = false  # Indica si las cartas están mostrando el reverso

# Called when the node enters the scene tree for the first time.
func _ready():
	update_button_text()



func _on_options_button_pressed():
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")


func _on_reverse_anverse_toggle_button_pressed():
	GlobalData.toggle_reverses()  # Alterna entre reverso y anverso
	update_button_text()  # Actualiza el texto del botón
	emit_signal("reverse_anverse_toggled", showing_reverses)  # Emite la señal con el estado actual
	

# Actualiza el texto del botón
func update_button_text():
	if GlobalData.showing_reverses:
		reverse_anverse_toggle_button.text = "Anverso"  # Cambia el texto a "Anverso"
		showing_reverses = true
	else:
		reverse_anverse_toggle_button.text = "Reverso"  # Cambia el texto a "Reverso"texto a "Reverso"
		showing_reverses = false
