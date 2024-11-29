# ===============================
# Nombre del Script: game_config.gd
# Desarrollador: Carlos Alcaraz Benítez
# Fecha de Creación: 07 de Noviembre de 2024
# Descripción: Singleton para la configuración del modo de partida y de la dificultad de la partida
# Convertimos el Singleton (Autoload) en la configuración del proyecto y añadimos el script GameConfig
# ===============================
extends Node

# Enum de dificultad
#enum Difficulty { ESTUDIANTE, PROFESOR, PSICOLOGO }

# Modo de partida
var game_mode: String = "Estrategia"


# Dificultad de la IA: "Estudiante", "Profesor", "Psicólogo"
#var ia_difficulty: Difficulty = Difficulty.PROFESOR  # Valor por defecto

# Opciones
var music_volume: int
var sfx_volume: int
var antialiasing_selected: int
var temp_antialiasing_selected: int
var ia_difficulty: int = 0


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
