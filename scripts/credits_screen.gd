# ===============================
# Nombre del Script: CredisScreen.gd
# Desarrollador: Carlos Alcaraz Benítez
# Fecha de Creación: 06 de Noviembre de 2024
# Descripción: Este script maneja la lógica de la pantalla de Créditos
# Se muestra texto con movimiento creado con nodo animationplayer
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
@onready var animation_player = $VBoxContainer/AnimationPlayer
@onready var audio_stream_player = $AudioStreamPlayer

func _ready():
	# Utiliza la variable global GameConfig donde se jugardan los datos de configuración del juego 
	# como en este caso los volúmenes.
	var volume_db = lerp(-80, 0, GameConfig.music_volume / 100.0)
	audio_stream_player.volume_db = volume_db
	#print("velocidad: " +str(animation_player.get_playing_speed()))
	#Ejecuta la animación a la mitad de velocidad. Ajusta la velocidad para mostrar la animación
	animation_player.play("credits_scroll", 0, 0.5)
	

	
# Señal de finalización de la animación
func _on_animation_player_animation_finished():
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")

#Señal de tecla escape presionada
func _unhandled_input(event):
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_ESCAPE:
			get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")
