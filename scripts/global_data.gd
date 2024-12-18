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
var user = ""
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
