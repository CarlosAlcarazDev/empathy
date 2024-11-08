# ===============================
# Nombre del Script: GameConfig.gd
# Desarrollador: Carlos Alcaraz Benítez
# Fecha de Creación: 07 de Noviembre de 2024
# Descripción: Singleton para la configuración del modo de partida y de la dificultad de la partida
# Convertimos el Singleton (Autoload) en la configuración del proyecto y añadimos el script GameConfig
# ===============================
extends Node

# Enum de dificultad
enum Difficulty { ESTUDIANTE, PROFESOR, PSICOLOGO }

# Modo de partida
var game_mode: String = ""

# Dificultad de la IA: "Estudiante", "Profesor", "Psicólogo"
var ia_difficulty: Difficulty = Difficulty.ESTUDIANTE  # Valor por defecto

# Opciones
var music_volume = 50
var sfx_volume = 50




# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
