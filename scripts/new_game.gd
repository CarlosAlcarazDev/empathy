# ===============================
# Nombre del Script: new_game.gd
# Desarrollador: Carlos Alcaraz Benítez
# Fecha de Creación: 06 de Noviembre de 2024
# Descripción: 
# ===============================
extends Control

@onready var reverse_anverse_toggle_button = $UI/ReverseAnverseToggleButton


# Called when the node enters the scene tree for the first time.
func _ready():
	# Reinicia combos y scores
	GlobalData.combo_ia = 0
	GlobalData.combo_player = 0
	GlobalData.hs_multiplier = 0
	GlobalData.re_multiplier = 0
	GlobalData.re_total_score = 0
	GlobalData.hs_total_score = 0
	GlobalData.total_ia_score = 0
	GlobalData.total_player_score = 0
	
