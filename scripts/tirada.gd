extends Resource
class_name Tirada

@export var numero_tirada: int          # Número de la tirada
@export var carta_bu: Dictionary        # Carta de bullying utilizada
@export var cartas_ia: Dictionary       # Cartas usadas por la IA
@export var cartas_jugador: Dictionary  # Cartas usadas por el jugador
@export var ganador_tirada: String      # Ganador de la tirada
@export var combos_ia: int              # Combos logrados por la IA
@export var combos_jugador: int         # Combos logrados por el jugador
@export var token_ia: Dictionary               # Tokens ganados por la IA
@export var token_jugador: Dictionary          # Tokens ganados por el jugador

# Constructor para inicializar la tirada
func _init(
	_numero_tirada: int,
	_carta_bu: Dictionary,
	_cartas_ia: Dictionary,
	_cartas_jugador: Dictionary,
	_ganador_tirada: String,
	_combos_ia: int,
	_combos_jugador: int,
	_token_ia: Dictionary,
	_token_jugador: Dictionary
):
	self.numero_tirada = _numero_tirada
	self.carta_bu = _carta_bu
	self.cartas_ia = _cartas_ia
	self.cartas_jugador = _cartas_jugador
	self.ganador_tirada = _ganador_tirada
	self.combos_ia = _combos_ia
	self.combos_jugador = _combos_jugador
	self.token_ia = _token_ia
	self.token_jugador = _token_jugador

	# Depuración
	print("Tirada creada:")
	print("Número de tirada:", numero_tirada)
	print("Carta BU:", carta_bu)
	print("Cartas IA:", cartas_ia)
	print("Cartas Jugador:", cartas_jugador)
	print("Ganador de la tirada:", ganador_tirada)
	print("Combos IA:", combos_ia)
	print("Combos Jugador:", combos_jugador)
	print("Tokens IA:", token_ia)
	print("Tokens Jugador:", token_jugador)
