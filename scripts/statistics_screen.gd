# ===============================
# Nombre del Script: StatisticsScreen.gd
# Desarrollador: Carlos Alcaraz Benítez
# Fecha de Creación: 07 de Noviembre de 2024
# Descripción: Este script maneja la lógica de la pantalla de Estadísticas (Métricas)
# Se muestra texto con información del usuario y estadísticas de sus partidas
# Por ahora tan solo muestra información del usuario
# Las métricas deberán recogerse a medida que genere información con las partidas
# Pulsar tecla Esc para salir
# ===============================
# Listado de funciones
# 
#	_ready(): Cargar configuración juego al iniciar
#	_on_animation_player_animation_finished(): Señal de finalización de la animación
#	_unhandled_input(event): Señal de tecla escape presionada
# ===============================

extends Control

# Referencias a los nodos de la escena
@onready var id_player = $VBoxContainer/IDHBoxContainer/IDPlayer
@onready var username_player = $VBoxContainer/UsernameHBoxContainer/UsernamePlayer
@onready var date_player = $VBoxContainer/DateHBoxContainer/DatePlayer


# Función para cargar información del usuario
func _ready():
	id_player.text = str(GlobalData.id)  # Asignar el ID al Label de ID
	username_player.text = GlobalData.user  # Asignar el nombre de usuario al Label de Username
	# Formatear la fecha de creación
	var created_at = GlobalData.created_at
	var date_text = str(created_at.day) + "/" + str(created_at.month) + "/" + str(created_at.year)
	date_player.text = date_text  # Asignar la fecha formateada al Label de Fecha Explicación

#Señal de tecla escape presionada
func _unhandled_input(event):
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_ESCAPE:
			get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")
