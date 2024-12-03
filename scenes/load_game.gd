extends Control

@onready var item_list = $ItemList  # Reemplaza con la ruta de tu ItemList en la escena

@onready var load_button = $VBoxContainer/LoadButton
@onready var back_button = $VBoxContainer/BackButton

# Ruta del archivo JSON donde se almacenan los datos de guardar partidas
const SAVE_DATA_FILE := "user://save.json"

func load_saved_games(player_id: int):
	print("Cargando partidas guardadas para el jugador:", player_id)
	var all_games
	if FileAccess.file_exists(SAVE_DATA_FILE):
		print("Archivo encontrado:", SAVE_DATA_FILE)
		var file = FileAccess.open(SAVE_DATA_FILE, FileAccess.READ)
		if file:
			print("Archivo abierto correctamente.")
			var _size = file.get_length()
			print("Tamaño del archivo:", _size)

			if _size > 0:
				var existing_content = file.get_as_text()
				print("Contenido del archivo:", existing_content)
				var parse_result = JSON.parse_string(existing_content)
				print("save: parse_result", parse_result)
				all_games = parse_result
			else:
				print("El archivo está vacío.")
			file.close()
		else:
			print("No se pudo abrir el archivo para lectura.")
	# Filtrar partidas por el ID del jugador
	
	var player_games = all_games.filter(func(p): return p.player_id == player_id)

	# Ordenar las partidas por fecha/hora (opcional)
	#player_games.sort_custom(self, "_sort_by_timestamp")
	print("load: player_Games: ", player_games)
	return player_games

# Método auxiliar para ordenar partidas por fecha/hora
func _sort_by_timestamp(a, b):
	return a.timestamp < b.timestamp


func populate_saved_games():
	var player_id = GlobalData.id
	print("Mostrando partidas guardadas para el jugador:", player_id)

	var saved_games = load_saved_games(player_id)
	print("saved_games: ", saved_games)
	if saved_games.size() == 0:
		print("No se encontraron partidas guardadas para el jugador.")
		item_list.clear()
		item_list.add_item("No hay partidas guardadas disponibles.")
		return

	# Poblamos el ItemList con las partidas guardadas
	item_list.clear()
	for game in saved_games:
		var item_text = ""
		var ia_description = ""
		print("load: ia_dificulty", game["ia_difficulty"])
		var ia_value = int(game["ia_difficulty"])
		match ia_value:
			0:
				ia_description = "IA Alumno"
			1:
				ia_description = "IA Profesor"
			2:
				ia_description = "IA Psicólogo"
			_:
				ia_description = "IA Desconocida"

		item_text += "\n" + game.timestamp + " - " + "Modo: " + game["game_mode"] + " | " + ia_description + " | Jugador: " + str(game["player_score"]) + " IA: " + str(game["ai_score"])
		
		item_list.add_item(item_text)

var selected_game_index = -1  # Variable para almacenar el índice seleccionado

func on_item_selected(index):
	print("Partida seleccionada:", index)
	selected_game_index = index  # Guarda el índice seleccionado
	
func on_load_button_pressed():
	if selected_game_index == -1:
		print("No se ha seleccionado ninguna partida.")
		return
	print("load partida seleccionada", selected_game_index)
	var player_id = GlobalData.id
	var selected_game = load_saved_game_by_index(player_id, selected_game_index)

	print("load Cargando partida seleccionada:", selected_game)

	# Almacenar los datos de la partida en el singleton
	GlobalData.saved_game_data = selected_game
	
	# Cambiar a la escena del juego
	get_tree().change_scene_to_file("res://scenes/NewGame.tscn")




# Función para regresar a la pantalla anterior
func on_back_button_pressed():
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")  # Cambia a la escena del menú principal

func load_saved_game_by_index(player_id: int, game_index: int) -> Dictionary:
	print("Cargando partida guardada para el jugador:", player_id, "y el índice:", game_index)

	# Obtén todas las partidas guardadas para el jugador
	var saved_games = load_saved_games(player_id)
	print("12Partidas disponibles para el jugador:", saved_games)

	# Verifica que el índice es válido
	if game_index >= 0 and game_index < saved_games.size():
		return saved_games[game_index]
	else:
		print("Índice de partida inválido:", game_index)
		return {}


# Inicialización
func _ready():
	populate_saved_games()
	item_list.connect("item_selected", Callable(self, "on_item_selected"))
	load_button.connect("pressed", Callable(self, "on_load_button_pressed"))
	back_button.connect("pressed", Callable(self, "on_back_button_pressed"))
