extends Control

@onready var id_player = $VBoxContainer/IDHBoxContainer/IDPlayer
@onready var username_player = $VBoxContainer/UsernameHBoxContainer/UsernamePlayer
@onready var date_player = $VBoxContainer/DateHBoxContainer/DatePlayer


func _ready():

	# Asegurarse de que los valores de GlobalData se asignan a los Labels
	id_player.text = str(GlobalData.id)  # Asignar el ID al Label de ID
	username_player.text = GlobalData.user  # Asignar el nombre de usuario al Label de Username
	# Formatear la fecha de creación
	var created_at = GlobalData.created_at
	var date_text = str(created_at.day) + "/" + str(created_at.month) + "/" + str(created_at.year)
	date_player.text = date_text  # Asignar la fecha formateada al Label de Fecha Explicación

func _unhandled_input(event):
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_ESCAPE:
			get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")
