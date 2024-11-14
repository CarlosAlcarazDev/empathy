# global_data.gd
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

# Variable global para rastrear la carta que está en TARGET_POSITION
var current_card_in_target_positionRE = null
var current_card_in_target_positionHS = null

# Variable global para rastrear la carta que está en TARGET_POSITION
var id_current_card_in_target_positionRE = 0
var id_current_card_in_target_positionHS = 0
