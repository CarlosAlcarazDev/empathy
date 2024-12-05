extends Resource
class_name Game

@export var nombre_jugador: String
@export var id_jugador: int
@export var numero_partida: int
@export var modo_juego: String
@export var ia_dificultad: int
@export var tiradas: Array             # Lista de tiradas (objetos `Tirada`)
@export var ganador: String
@export var tiempo_total_partida: int
@export var partida_abandonada: bool
@export var token_ia: Dictionary               # Tokens ganados por la IA
@export var token_jugador: Dictionary          # Tokens ganados por el jugador




func _init(
	_nombre_jugador: String,
	_id_jugador: int,
	_modo_juego: String,
	_ia_dificultad: int,
	_ganador := "",
	_tiempo_total_partida := 0,
	_partida_abandonada := false
	
):
	print("Inicializando la partida...")

	self.nombre_jugador = _nombre_jugador
	self.id_jugador = _id_jugador
	self.numero_partida = get_next_game_number(_id_jugador)
	self.modo_juego = _modo_juego
	self.ia_dificultad = _ia_dificultad
	self.tiradas = []  # Comienza como una lista vacía
	self.ganador = _ganador
	self.tiempo_total_partida = _tiempo_total_partida
	self.partida_abandonada = _partida_abandonada

	# Comprobar el estado inicial
	print("Datos iniciales de la partida:")
	print("Nombre del jugador:", nombre_jugador)
	print("ID del jugador:", id_jugador)
	print("Número de partida:", numero_partida)
	print("Modo de juego:", modo_juego)
	print("Dificultad IA:", ia_dificultad)
	print("Tiradas iniciales:", tiradas)
	print("Ganador inicial:", ganador)
	print("Tiempo total partida:", tiempo_total_partida)
	print("Partida abandonada:", partida_abandonada)

# Método para añadir una tirada a la partida
func add_tirada(tirada: Tirada):
	self.tiradas.append(tirada)


# Método para calcular el número de partida
func get_next_game_number(id_jugador: int) -> int:
	# Cargar datos guardados
	var saved_data = load_saved_games()

	# Buscar partidas del jugador con el id_jugador dado
	for jugador_partidas in saved_data["partidas"]:
		if jugador_partidas["id_jugador"] == id_jugador:
			# Si el jugador tiene partidas, calcular el número más alto
			var max_numero = 0
			for partida in jugador_partidas["partidas"]:
				max_numero = max(max_numero, partida["numero_partida"])
			print("Número de partida calculado para el jugador", id_jugador, ":", max_numero + 1)
			return max_numero + 1

	# Si el jugador no tiene partidas registradas, comenzar desde 1
	print("Número de partida calculado para el jugador", id_jugador, ": 1 (nuevo jugador)")
	return 1


# Método para mostrar los datos de la partida
func mostrar_datos():
	print("Datos de la partida actual:")
	print("Nombre del jugador:", nombre_jugador)
	print("ID del jugador:", id_jugador)
	print("Número de partida:", numero_partida)
	print("Modo de juego:", modo_juego)
	print("Dificultad IA:", ia_dificultad)
	print("Ganador:", ganador)
	print("Tiempo total partida:", tiempo_total_partida)
	print("Partida abandonada:", partida_abandonada)
	print("Tiradas:")
	for tirada in tiradas:
		tirada._print_properties()

func load_saved_games() -> Dictionary:
	const SAVE_FILE_PATH = "user://game.json"
	var file = FileAccess.open(SAVE_FILE_PATH, FileAccess.READ)
	if not file:
		print("Archivo de partidas no encontrado, creando un nuevo registro...")
		return {"partidas": []}
	if file:
		var data = file.get_as_text()
		var json = JSON.new()
		var parse_result = json.parse_string(data)
		return parse_result

	print("Error al cargar los datos guardados.")
	return {"partidas": []}
