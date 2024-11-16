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
@onready var countdown_30_seconds_label = $Countdown30SecondsLabel

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Señal boton presionado en opciones
func _on_options_texture_button_pressed():
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")
