# ===============================
# Nombre del Script: global_data.gd
# Desarrollador: Carlos Alcaraz Benítez
# Fecha de Creación: 07 de Noviembre de 2024
# Descripción: Script que funciona como un singleton, (autoload) en Godot. Estará disponible en cualquier
# parte del proyecto. 
# Guardamos:
#	Variables de usuario
#	Cartas seleccionadas (deprecated por usar señales para saber qué cartas han sido usadas)
# ===============================

extends Node

# Variables del usuario
var user = "Carlos"
var id
var password = "Fireblade25*"
var created_at = {
			"day": 9,
			"dst": false,
			"hour": 0,
			"minute": 2,
			"month": 11,
			"second": 32,
			"weekday": 6,
			"year": 2024
		}

# Variable global para rastrear la carta que está en TARGET_POSITION (deprecated)
var current_card_in_target_positionRE = null
var current_card_in_target_positionHS = null

# Variable global para rastrear la id que está en TARGET_POSITION (deprecated)
var id_current_card_in_target_positionRE = 0
var id_current_card_in_target_positionHS = 0

# Variable global que controla si las cartas muestran el reverso o el anverso
var showing_reverses = false  # False por defecto (mostrando anverso)

# Alterna entre reverso y anverso
func toggle_reverses():
	showing_reverses = !showing_reverses
	
# Score Total 
var total_player_score: float = 0.0
var total_ia_score: float = 0.0

#Partial Score
var re_total_score: float = 0.0
var hs_total_score: float = 0.0

#Multiplier
var re_multiplier: float = 0.0
var hs_multiplier: float = 0.0

#Combos
var combo_player: int = 0
var combo_ia: int = 0
# Declarar la nueva variable token_combos
var token_combos_player: Dictionary = {
	"verbal": 0,
	"exclusión_social": 0,
	"psicológico": 0,
	"físico": 0,
	"sexual": 0,
	"ciberbullying": 0
}
var token_combos_ia: Dictionary = {
	"verbal": 0,
	"exclusión_social": 0,
	"psicológico": 0,
	"físico": 0,
	"sexual": 0,
	"ciberbullying": 0
}
# Declarar la nueva variable token_combos
var token_earned_player: Dictionary = {
	"verbal": 0,
	"exclusión_social": 0,
	"psicológico": 0,
	"físico": 0,
	"sexual": 0,
	"ciberbullying": 0
}
var token_earned_ia: Dictionary = {
	"verbal": 0,
	"exclusión_social": 0,
	"psicológico": 0,
	"físico": 0,
	"sexual": 0,
	"ciberbullying": 0
}


#Abort
var game_over_abort = false
var game_over_time_or_bu = false


# Método para convertir un entero en texto de dificultad
func get_difficulty_text(difficulty: int) -> String:
	match difficulty:
		0:
			return "Estudiante"
		1:
			return "Profesor"
		2:
			return "Psicólogo"
		_:
			return "Desconocido"

#Datos partida guardada
var saved_game_data: Dictionary = {}

#Datos de finalizacion de turno
var final_countdown_turn: int = 0

# Datos compartidos
var token_data = {}

# Método para configurar los datos
func set_token_data(data: Dictionary):
	token_data = data

# Método para obtener los datos
func get_token_data() -> Dictionary:
	return token_data
	
# Datos compartidos
var games_data = {}

# Método para configurar los datos
func set_games_data(data: Dictionary):
	games_data = data

# Método para obtener los datos
func get_games_data() -> Dictionary:
	return games_data

# Datos compartidos
var average_data = {}

# Método para configurar los datos
func set_average_data(data: Dictionary):
	average_data = data

# Método para obtener los datos
func get_average_data() -> Dictionary:
	return average_data
