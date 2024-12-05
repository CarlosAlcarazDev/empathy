# ===============================
# Nombre del Script: StatisticsScreen.gd
# Desarrollador: Carlos Alcaraz Benítez
# Fecha de Creación: 07 de Noviembre de 2024
# Descripción: Este script maneja la lógica de la pantalla de Estadísticas (Métricas)
# Se muestra texto con información del usuario y estadísticas de sus partidas
# Por ahora tan solo muestra información del usuario
# Las métricas deberán recogerse a medida que genere información con las partidas
# Pulsar tecla Esc para salir
# ===============================
# Listado de funciones
# 
#	_ready(): Cargar configuración juego al iniciar
#	_on_animation_player_animation_finished(): Señal de finalización de la animación
#	_unhandled_input(event): Señal de tecla escape presionada
# ===============================

extends Control

# Referencias a los nodos de la escena
@onready var id_player = $VBoxContainer2/IDHBoxContainer/IDPlayer
@onready var username_player = $VBoxContainer2/UsernameHBoxContainer/UsernamePlayer
@onready var date_player = $VBoxContainer2/DateHBoxContainer/DatePlayer



@onready var total_games_player_label = $VBoxContainer/UsernameHBoxContainer2/TotalGamesPlayerLabel
@onready var abandoned_games_player_label = $VBoxContainer/DateHBoxContainer2/AbandonedGamesPlayerLabel
@onready var completed_games_player_label = $VBoxContainer/DateHBoxContainer3/CompletedGamesPlayerLabel
@onready var average_duration_player_label = $VBoxContainer/DateHBoxContainer4/AverageDurationPlayerLabel
@onready var average_intuition_player_label = $VBoxContainer/DateHBoxContainer5/AverageIntuitionPlayerLabel
@onready var average_strategy_player_label = $VBoxContainer/DateHBoxContainer8/AverageStrategyPlayerLabel
@onready var average_ia_alumno_player_label = $VBoxContainer/DateHBoxContainer16/AverageIaAlumnoPlayerLabel
@onready var average_ia_profesor_player_label = $VBoxContainer/DateHBoxContainer17/AverageIAProfesorPlayerLabel
@onready var average_ia_psicologo_player_label = $VBoxContainer/DateHBoxContainer18/AverageIAPsicologoPlayerLabel

@onready var draw_player_label = $VBoxContainer/DateHBoxContainer19/DrawPlayerLabel
@onready var win_player_label = $VBoxContainer/DateHBoxContainer6/WinPlayerLabel
@onready var losser_player_label = $VBoxContainer/DateHBoxContainer9/LosserPlayerLabel
@onready var abandons_player_label = $VBoxContainer/DateHBoxContainer10/AbandonsPlayerLabel
@onready var average_combos_player_label = $VBoxContainer/DateHBoxContainer11/AverageCombosPlayerLabel
@onready var max_combos_player_label = $VBoxContainer/DateHBoxContainer7/MaxCombosPlayerLabel
@onready var average_turn_player_label = $VBoxContainer/DateHBoxContainer12/AverageTurnPlayerLabel
@onready var total_tiradas_player_label = $VBoxContainer/DateHBoxContainer13/TotalTiradasPlayerLabel
@onready var player_win_tiradas_label = $VBoxContainer/DateHBoxContainer14/PlayerWinTiradasLabel
@onready var ratio_player_win_tiradas_label = $VBoxContainer/DateHBoxContainer15/RatioPlayerWinTiradasLabel


@onready var token_analysis_player_label = $VBoxContainer3/DateHBoxContainer2/TokenAnalysisPlayerLabel
@onready var token_psicologico_player_label = $VBoxContainer3/DateHBoxContainer3/TokenPsicologicoPlayerLabel
@onready var token_verbal_player_label = $VBoxContainer3/DateHBoxContainer4/TokenVerbalPlayerLabel
@onready var token_ciberbullying_player_label = $VBoxContainer3/DateHBoxContainer5/TokenCiberbullyingPlayerLabel
@onready var token_exclusion_player_label = $VBoxContainer3/DateHBoxContainer6/TokenExclusionPlayerLabel
@onready var token_fisico_player_label = $VBoxContainer3/DateHBoxContainer7/TokenFisicoPlayerLabel
@onready var token_sexual_player_label = $VBoxContainer3/DateHBoxContainer8/TokenSexualPlayerLabel
@onready var feedback_label = $FeedbackLabel

# Variable para almacenar la fuente personalizada
var font_resource: Font = preload("res://assets/fonts/Roboto-Medium.ttf")

#Señal de tecla escape presionada
func _unhandled_input(event):
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_ESCAPE:
			get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")


const SAVE_FILE_PATH = "user://game.json"
# Variable para almacenar los datos
var token_data = {}

# Variables para almacenar estadísticas
var player_statistics = {}
var tirada_statistics = {}
var token_statistics = {}
var general_statistics = {}


func _ready():

	# Obtener datos del singleton

	
	id_player.text = str(GlobalData.id)  # Asignar el ID al Label de ID
	username_player.text = GlobalData.user  # Asignar el nombre de usuario al Label de Username
	# Formatear la fecha de creación
	var created_at = GlobalData.created_at
	var date_text = str(created_at.day) + "/" + str(created_at.month) + "/" + str(created_at.year)
	date_player.text = date_text  # Asignar la fecha formateada al Label de Fecha Explicación

	
	var saved_data = load_saved_games()
	player_statistics = calculate_player_statistics(saved_data)
	tirada_statistics = calculate_tirada_statistics(saved_data)
	token_statistics = calculate_negative_metrics(saved_data)
	general_statistics = calculate_general_statistics(saved_data)
	# Generar feedback
	var feedback = generate_feedback()
	feedback_label.text = feedback  # Mostrar el feedback en pantalla (en un Label o RichTextLabel)
	print(feedback)  # También imprimirlo en la consola
	
	if saved_data:
		# Filtrar datos del usuario actual
		var user_data = filter_user_data(GlobalData.id, saved_data)
		if user_data["partidas"].size() == 0:
			print("No data found for player ID:", GlobalData.id)
			return

		# Calcular estadísticas generales
		print("\n--- General Statistics for Player ---")
		var general_stats = calculate_general_statistics(user_data)
		total_games_player_label.text = str(general_stats["total_games"])
		abandoned_games_player_label.text = str(general_stats["abandoned_games"])
		completed_games_player_label.text = str(general_stats["completed_games"])
		var average_duration_seconds = general_stats["average_duration"]
		var total_seconds = int(average_duration_seconds)
		var minutes = (total_seconds / 60)
		var seconds = (total_seconds % 60)
		average_duration_player_label.text = "%02d:%02d" % [minutes, seconds]
		# Calcular estadísticas del jugador logueado
		print("\n--- Player Statistics ---")
		var player_stats = calculate_player_statistics(user_data)
		
		var player_name = user_data["partidas"][0]["jugador"]
		win_player_label.text = str(player_stats["wins"])
		draw_player_label.text = str(player_stats["draws"])
		losser_player_label.text = str(player_stats["losses"])
		abandons_player_label.text = str(player_stats["abandons"])
		average_combos_player_label.text = str("%.2f" % player_stats["average_combos"]) + (" %")
		max_combos_player_label.text = str(player_stats["max_combos"])
		var average_turn_seconds = player_stats["average_turn_time"]
		total_seconds = int(average_turn_seconds)
		minutes = int(total_seconds / 60)
		seconds = int(total_seconds % 60)
		average_turn_player_label.text = "%02d:%02d" % [minutes, seconds]
		print("average_intuition:", player_stats["average_intuition"])
		print("average_strategy:", player_stats["average_strategy"])
		average_intuition_player_label.text = str("%.2f" % player_stats["average_intuition"]) + (" %")
		average_strategy_player_label.text = str("%.2f" % player_stats["average_strategy"]) + (" %")
		average_ia_alumno_player_label.text = str("%.2f" % player_stats["average_alumno"]) + (" %")
		average_ia_profesor_player_label.text = str("%.2f" % player_stats["average_profesor"]) + (" %")
		average_ia_psicologo_player_label.text = str("%.2f" % player_stats["average_psicologo"]) + (" %")
				
		print("\n--- Tirada Statistics ---")
		var tirada_stats = calculate_tirada_statistics(saved_data)
		for key in tirada_stats.keys():
			if key == "most_used_cards":
				print(key, ":")
				for card in tirada_stats[key].keys():
					print("   ", card, ": ", tirada_stats[key][card])
			else:
				print(key, ": ", tirada_stats[key])
			total_tiradas_player_label.text = str(tirada_stats["total_tiradas"])
			player_win_tiradas_label.text = str(tirada_stats["player_win"])
			ratio_player_win_tiradas_label.text = str("%.2f" % tirada_stats["player_win_rate"]) + (" %")
		print("\n--- Card Analysis ---") 
		var card_stats = analyze_cards(saved_data)
		print("Card Effectiveness:")
		for card in card_stats["card_effectiveness"].keys():
			print("   ", card, ": ", card_stats["card_effectiveness"][card])
		print("HS Distribution:")
		for hs in card_stats["hs_distribution"].keys():
			print("   ", hs, ": ", card_stats["hs_distribution"][hs])

		print("\n--- Advanced Metrics ---")
		var advanced_metrics = calculate_advanced_metrics(saved_data)
		for key in advanced_metrics.keys():
			print(key, ": ", advanced_metrics[key])


	# Calculamos las métricas negativas
	var negative_metrics = calculate_negative_metrics(saved_data)
	# Guardar los datos en el Singleton
	GlobalData.set_token_data(negative_metrics["token_analysis"])

	# Acceder a `token_analysis` y mostrar en consola
	var total_tokens = 0
	print("\n--- Token Analysis ---")
	for token_type in negative_metrics["token_analysis"]:
		total_tokens += negative_metrics["token_analysis"][token_type]
	token_analysis_player_label.text = str(total_tokens)
	token_ciberbullying_player_label.text = str(negative_metrics["token_analysis"]["ciberbullying"])
	token_exclusion_player_label.text = str(negative_metrics["token_analysis"]["exclusión_social"])
	token_fisico_player_label.text = str(negative_metrics["token_analysis"]["físico"])
	token_psicologico_player_label.text = str(negative_metrics["token_analysis"]["psicológico"])
	token_sexual_player_label.text = str(negative_metrics["token_analysis"]["sexual"])
	token_verbal_player_label.text = str(negative_metrics["token_analysis"]["verbal"])
	# Acceder a `tokens_per_game` y mostrar en consola
	print("\n--- Tokens per Game ---")
	for i in range(negative_metrics["tokens_per_game"].size()):
		print("Game", i + 1, "tokens:", negative_metrics["tokens_per_game"][i])
	
	# Acceder a `bullying_card_frequency` y mostrar en consola
	print("\n--- Bullying Card Frequency ---")
	for card in negative_metrics["bullying_card_frequency"]:
		print(card, ": ", negative_metrics["bullying_card_frequency"][card])

# Función para convertir segundos a formato mm:ss 
func format_time(seconds: int) -> String: 
	var minutes = int(seconds / 60) 
	var remaining_seconds = seconds % 60 
	return str("%02d:%02d" % [minutes, remaining_seconds])
	
func load_saved_games() -> Dictionary:
	
	var file = FileAccess.open(SAVE_FILE_PATH, FileAccess.READ)
	if not file:
		print("Archivo de partidas no encontrado, creando un nuevo registro...")
		return {}
	if file:
		var data = file.get_as_text()
		var json = JSON.new()
		var parse_result = json.parse_string(data)
		return parse_result
	print("Error al cargar los datos guardados.")
	return {}
	
	
func filter_user_data(player_id: int, data: Dictionary) -> Dictionary:
	for player in data["partidas"]:
		if player["id_jugador"] == player_id:
			return {"partidas": [player]}  # Retornar solo las partidas del jugador
	return {"partidas": []}  # Retornar vacío si no se encuentra el jugador

func calculate_general_statistics(data: Dictionary) -> Dictionary:
	var partidas = data["partidas"]
	var total_games = 0
	var abandoned_games = 0
	var completed_games = 0
	var total_duration = 0

	for player in partidas:
		for partida in player["partidas"]:
			total_games += 1
			total_duration += partida["tiempo_total_partida"]
			if partida["partida_abandonada"]:
				abandoned_games += 1
			elif partida["ganador"] != "":
				completed_games += 1

	return {
		"total_games": total_games,
		"abandoned_games": abandoned_games,
		"completed_games": completed_games,
		"average_duration": total_duration / total_games if total_games > 0 else 0
	}

func calculate_player_statistics(data: Dictionary) -> Dictionary:
	var player = data["partidas"][0]  # El jugador ya está filtrado en user_data
	var wins = 0
	var losses = 0
	var abandons = 0
	var draws = 0
	var total_combos = 0
	var max_combos = 0
	var total_turn_time = 0
	var total_tiradas = 0
	var estrategia = 0
	var intuicion = 0
	var dificultad_ia_alumno = 0
	var dificultad_ia_profesor = 0
	var dificultad_ia_psicologo = 0
	var total_games = player["partidas"].size()

	for partida in player["partidas"]:
		if partida["ganador"] == "VICTORIA":
			wins += 1
		if partida["ganador"] == "DERROTA":
			losses += 1
		if partida["ganador"] == "EMPATE":
			draws += 1
		if partida["partida_abandonada"]:
			abandons += 1
		if partida["modo_juego"] == "Estrategia":
			estrategia += 1
		if partida["modo_juego"] == "Intuición":
			intuicion += 1
		if partida["nivel_dificultad"] == 0:
			dificultad_ia_alumno += 1
		if partida["nivel_dificultad"] == 1:
			dificultad_ia_profesor += 1
		if partida["nivel_dificultad"] == 2:
			dificultad_ia_psicologo += 1
		

		for tirada in partida["tiradas"]:
			total_combos += tirada["combos_jugador"]
			max_combos = max(max_combos, tirada["combos_jugador"])
			total_turn_time += tirada["cartas_jugador"]["tiempo_turno"]
			total_tiradas += 1
			
	# Crear una variable para los datos relevantes
	var game_summary = {
		"wins": wins,
		"losses": losses,
		"draws": draws,
		"abandons": abandons
	}

	# Enviar los datos al singleton global
	GlobalData.set_games_data(game_summary)
	
		# Crear una variable para los datos relevantes
	var average_summary = {
		"average_strategy": (estrategia *1.0/ total_games) * 100,
		"average_intuition": (intuicion *1.0/ total_games) * 100,
		"average_alumno": (dificultad_ia_alumno *1.0/ total_games) * 100,
		"average_profesor": (dificultad_ia_profesor *1.0 / total_games) * 100,
		"average_psicologo": (dificultad_ia_psicologo *1.0/ total_games) * 100
	}

	# Enviar los datos al singleton global
	GlobalData.set_average_data(average_summary)
	
	
	return {
		"player_name": player["jugador"],
		"wins": wins,
		"losses": losses,
		"draws": draws,
		"abandons": abandons,
		"average_combos": total_combos / total_tiradas if total_tiradas > 0 else 0,
		"max_combos": max_combos,
		"average_turn_time": total_turn_time / total_tiradas if total_tiradas > 0 else 0,
		"average_strategy": (estrategia *1.0/ total_games) * 100,
		"average_intuition": (intuicion *1.0/ total_games) * 100,
		"average_alumno": (dificultad_ia_alumno *1.0/ total_games) * 100,
		"average_profesor": (dificultad_ia_profesor *1.0 / total_games) * 100,
		"average_psicologo": (dificultad_ia_psicologo *1.0/ total_games) * 100,
		
	}

func calculate_tirada_statistics(data: Dictionary) -> Dictionary:
	var total_tiradas = 0
	var player_wins = 0
	var ia_wins = 0
	var draws = 0
	var card_usage = {}

	# Obtener el ID del usuario logueado
	var logged_user_id = GlobalData.id  # Asegúrate de configurar este ID en tu Singleton

	# Filtrar las partidas del usuario logueado
	for player in data["partidas"]:
		if player["id_jugador"] == logged_user_id:  # Solo procesar las partidas del usuario logueado
			for partida in player["partidas"]:
				for tirada in partida["tiradas"]:
					total_tiradas += 1
					if tirada["ganador_tirada"] == "Jugador":
						player_wins += 1
					elif tirada["ganador_tirada"] == "IA":
						ia_wins += 1
					elif tirada["ganador_tirada"] == "Empate":
						draws += 1

					var card = tirada["carta_bu"]["nombre"]
					if not card_usage.has(card):
						card_usage[card] = 0
					card_usage[card] += 1

	return {
		"total_tiradas": total_tiradas,
		"player_win": player_wins,
		"ia_win": ia_wins,
		"player_win_rate": (player_wins * 1.0 / total_tiradas) * 100 if total_tiradas > 0 else 0,
		"ia_win_rate": (ia_wins * 1.0 / total_tiradas) * 100 if total_tiradas > 0 else 0,
		"DEPRECATED most_used_cards": card_usage
	}



func analyze_cards(data: Dictionary) -> Dictionary:
	var card_effectiveness = {}
	var hs_distribution = {}
	var re_distribution = {}

	for player in data["partidas"]:
		for partida in player["partidas"]:
			for tirada in partida["tiradas"]:
				var card = tirada["carta_bu"]["nombre"]
				if not card_effectiveness.has(card):
					card_effectiveness[card] = {"wins": 0, "total": 0}
				card_effectiveness[card]["total"] += 1
				if tirada["ganador_tirada"] == "Jugador":
					card_effectiveness[card]["wins"] += 1

				var hs = tirada["cartas_jugador"]["hs"]
				if not hs_distribution.has(hs):
					hs_distribution[hs] = 0
				hs_distribution[hs] += 1
				var re = tirada["cartas_jugador"]["re"]
				if not re_distribution.has(re):
					re_distribution[re] = 0
				re_distribution[re] += 1

	return {
		"card_effectiveness": card_effectiveness,
		"hs_distribution": hs_distribution,
		"re_distribution": re_distribution
	}

func calculate_advanced_metrics(data: Dictionary) -> Dictionary:
	var abandon_rate = 0
	var total_games = 0
	var abandoned_games = 0
	var total_combos = 0
	var victories_with_combos = 0

	for player in data["partidas"]:
		for partida in player["partidas"]:
			total_games += 1
			if partida["partida_abandonada"]:
				abandoned_games += 1
			for tirada in partida["tiradas"]:
				total_combos += tirada["combos_jugador"]
				if tirada["ganador_tirada"] == "Jugador" and tirada["combos_jugador"] > 0:
					victories_with_combos += 1

	return {
		"abandon_rate": abandoned_games / total_games if total_games > 0 else 0,
		"combo_victory_rate": victories_with_combos / total_games if total_games > 0 else 0
	}
	
func calculate_negative_metrics(data: Dictionary) -> Dictionary:
	var total_tokens = {"psicológico": 0, "verbal": 0, "ciberbullying": 0, "exclusión_social": 0, "físico": 0, "sexual": 0}
	var bullying_related_cards = {}
	var tokens_per_game = []  # Lista para almacenar tokens por partida

	# Obtener el ID del usuario logueado
	var logged_user_id = GlobalData.id

	# Filtrar las partidas del usuario logueado
	for player in data["partidas"]:
		if player["id_jugador"] == logged_user_id:  # Solo procesar las partidas del usuario logueado
			for partida in player["partidas"]:
				var partida_tokens = {"psicológico": 0, "verbal": 0, "ciberbullying": 0, "exclusión_social": 0, "físico": 0, "sexual": 0}

				for tirada in partida["tiradas"]:
					for token in tirada["token_jugador"]:
						# Acumular tokens de esta partida
						partida_tokens[token] = tirada["token_jugador"][token]

					# Contabilizar cartas relacionadas con bullying
					var card = tirada["carta_bu"]["nombre"]
					if not bullying_related_cards.has(card):
						bullying_related_cards[card] = 0
					bullying_related_cards[card] += 1

				# Añadir los tokens de esta partida a la lista
				tokens_per_game.append(partida_tokens)

	# Iterar sobre cada partida en tokens_per_game para sumar los tokens totales
	for partida_tokens in tokens_per_game:
		for token in partida_tokens:
			total_tokens[token] += partida_tokens[token]

	return {
		"token_analysis": total_tokens,
		"tokens_per_game": tokens_per_game,
		"bullying_card_frequency": bullying_related_cards
	}
	


func generate_feedback() -> String:
	var feedback = ""
	feedback += "ANÁLISIS DE DATOS Y FEEDBACK\n"
	var average_turn_seconds = player_statistics["average_turn_time"]
	var total_seconds = int(average_turn_seconds)
	var minutes = int(total_seconds / 60)
	var seconds = int(total_seconds % 60)

	# Tiempo promedio de turnos
	var average_turn_time = player_statistics["average_turn_time"]
	if average_turn_time < 60:
		feedback += "Tu tiempo promedio de %02d:%02d segundos por turnos es muy bajo. Podrías estar eligiendo cartas al azar sin analizar bien tus opciones.\n" % [minutes, seconds]
	elif average_turn_time > 180:
		feedback += "Tu tiempo promedio de turnos es alto. Podrías estar sobreanalizando las decisiones. Trata de confiar más en tu intuición.\n"
	else:
		feedback += "Tu tiempo promedio de %d segundos por turnos es equilibrado. Sigue así y ajusta tu estrategia cuando sea necesario.\n" % average_turn_time

	# Partidas ganadas, perdidas, empatadas, abandonadas
	var wins = player_statistics["wins"]
	var losses = player_statistics["losses"]
	var draws = player_statistics["draws"]
	var abandons = player_statistics["abandons"]
	var total_games = wins + losses + draws + abandons

	# Asegúrate de que la división sea entre floats
	var win_rate = float(wins) / float(total_games) *100.0

	print("Wins:", wins, "Total Games:", total_games, "Win Rate:", win_rate)

	if win_rate > 70:
		feedback += "¡Increíble! Has ganado más del 70% de tus partidas. Considera probar un nivel de dificultad más alto.\n"
	elif win_rate > 50:
		feedback += "Tienes un buen porcentaje de victorias %d%%. Analiza tus derrotas para identificar mejoras estratégicas.\n" % win_rate
	else:
		feedback += "Tu porcentaje de victorias es bajo. Intenta analizar mejor tus movimientos y combina cartas estratégicamente.\n"

	if losses / total_games > 0.5:
		feedback += "Estás perdiendo muchas partidas. Esto puede indicar que necesitas comprender mejor las reglas o elegir mejor las cartas.\n"

	if draws / total_games > 0.3:
		feedback += "Tienes un alto porcentaje de partidas empatadas. Trata de usar realizar combos para cerrar las partidas.\n"

	if abandons / total_games > 0.2:
		feedback += "Abandonas muchas partidas. Esto puede ser un signo de frustración. Considera jugar en un nivel más cómodo o practicar estrategias básicas.\n"

	# Combos
	var average_combos = player_statistics["average_combos"]
	if average_combos < 2:
		feedback += "Tu promedio de combos es bajo [%d]. Intenta combinar cartas con mejor afinidad para ganar ventaja.\n" % average_combos
	elif average_combos > 2:
		feedback += "¡Impresionante! Tienes un alto promedio de combos [%d]. Esta estrategia es la correcta para conseguir más Tokens.\n" % average_combos
#
	## Tokens
	
	# Obtener los tokens sumados por partida
	var total_tokens = 0
	for token_type in token_statistics["token_analysis"]:
		total_tokens += token_statistics["token_analysis"][token_type]
	var average_tokens = total_tokens / general_statistics["total_games"]
	print (average_tokens)
	## Generar feedback
	if average_tokens < 3:
		feedback += "Estás obteniendo pocos tokens [%d] de promedio en tus partidas. Trata de realizar más combos.\n" % average_tokens
	elif average_tokens <= 5:
		feedback += "Tienes un rendimiento promedio con %d tokens. .\n" % average_tokens
	else:
		feedback += "¡Buen trabajo! Lograste %d tokens de promedio, lo cual indica que estás maximizando tus recursos.\n" % average_tokens
	#
	#
	# Modos de juego
	var average_strategy = player_statistics["average_strategy"]
	var average_intuition = player_statistics["average_intuition"]
	if average_strategy > average_intuition:
		feedback += "Prefieres el modo de Estrategia. Esto muestra que disfrutas planificar tus movimientos cuidadosamente.\n"
	elif average_intuition > average_strategy:
		feedback += "Prefieres el modo de Intuición. Esto indica que disfrutas jugar rápido y confiar en las estadísticas.\n"
	else:
		feedback += "Tienes un balance entre los modos de juego. Esto es excelente para adaptarte a diferentes desafíos.\n"

	# Dificultad
	var average_alumno = player_statistics["average_alumno"]
	var average_profesor = player_statistics["average_profesor"]
	var average_psicologo = player_statistics["average_psicologo"]
	if average_psicologo > 50:
		feedback += "Estás jugando principalmente en el nivel Psicólogo. ¡Eso es un gran desafío!\n"
	elif average_profesor > 50:
		feedback += "Estás jugando principalmente en el nivel Profesor. Esto es ideal para equilibrar dificultad y aprendizaje.\n"
	elif average_alumno > 50:
		feedback += "Estás jugando principalmente en el nivel Alumno. Considera aumentar la dificultad para poner a prueba tus habilidades.\n"

	return feedback
	
