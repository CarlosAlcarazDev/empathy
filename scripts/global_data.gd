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
var id = ""
var password = ""
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

#Abort
var abort = false
