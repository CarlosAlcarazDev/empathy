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


@onready var win_player_label = $VBoxContainer/DateHBoxContainer6/WinPlayerLabel
@onready var losser_player_label = $VBoxContainer/DateHBoxContainer9/LosserPlayerLabel
@onready var abandons_player_label = $VBoxContainer/DateHBoxContainer10/AbandonsPlayerLabel
@onready var average_combos_player_label = $VBoxContainer/DateHBoxContainer11/AverageCombosPlayerLabel
@onready var max_combos_player_label = $VBoxContainer/DateHBoxContainer7/MaxCombosPlayerLabel
@onready var average_turn_player_label = $VBoxContainer/DateHBoxContainer12/AverageTurnPlayerLabel
@onready var total_tiradas_player_label = $VBoxContainer/DateHBoxContainer13/TotalTiradasPlayerLabel
@onready var player_win_tiradas_label = $VBoxContainer/DateHBoxContainer14/PlayerWinTiradasLabel
@onready var ratio_player_win_tiradas_label = $VBoxContainer/DateHBoxContainer15/RatioPlayerWinTiradasLabel

#Señal de tecla escape presionada
func _unhandled_input(event):
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_ESCAPE:
			get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")


const SAVE_FILE_PATH = "user://game.json"

func _ready():
	id_player.text = str(GlobalData.id)  # Asignar el ID al Label de ID
	username_player.text = GlobalData.user  # Asignar el nombre de usuario al Label de Username
	# Formatear la fecha de creación
	var created_at = GlobalData.created_at
	var date_text = str(created_at.day) + "/" + str(created_at.month) + "/" + str(created_at.year)
	date_player.text = date_text  # Asignar la fecha formateada al Label de Fecha Explicación

	
	var saved_data = load_saved_games()
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
		average_duration_player_label.text = str("%.2f" % general_stats["average_duration"]) + (" s.")

		# Calcular estadísticas del jugador logueado
		print("\n--- Player Statistics ---")
		var player_stats = calculate_player_statistics(user_data)
		var player_name = user_data["partidas"][0]["jugador"]
		win_player_label.text = str(player_stats["wins"])
		losser_player_label.text = str(player_stats["losses"])
		abandons_player_label.text = str(player_stats["abandons"])
		average_combos_player_label.text = str("%.2f" % player_stats["average_combos"]) + (" %")
		max_combos_player_label.text = str(player_stats["max_combos"])
		average_turn_player_label.text = str("%.2f" % player_stats["average_turn_time"]) + (" s.")
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

		print("\n--- Negative Metrics ---")
		var negative_metrics = calculate_negative_metrics(saved_data)
		print("Token Analysis:")
		for token in negative_metrics["token_analysis"].keys():
			print("   ", token, ": ", negative_metrics["token_analysis"][token])
		print("Bullying Card Frequency:")
		for card in negative_metrics["bullying_card_frequency"].keys():
			print("   ", card, ": ", negative_metrics["bullying_card_frequency"][card])

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
	return {
		"player_name": player["jugador"],
		"wins": wins,
		"losses": losses,
		"abandons": abandons,
		"average_combos": total_combos / total_tiradas if total_tiradas > 0 else 0,
		"max_combos": max_combos,
		"average_turn_time": total_turn_time / total_tiradas if total_tiradas > 0 else 0,
		"average_strategy": (estrategia *1.0/ total_games) * 100,
		"average_intuition": (intuicion *1.0/ total_games) * 100,
		"average_alumno": (dificultad_ia_alumno *1.0/ total_games) * 100,
		"average_profesor": (dificultad_ia_profesor *1.0 / total_games) * 100,
		"average_psicologo": (dificultad_ia_psicologo *1.0/ total_games) * 100
	}


func calculate_tirada_statistics(data: Dictionary) -> Dictionary:
	var total_tiradas = 0
	var player_wins = 0
	var ia_wins = 0
	var draws = 0
	var card_usage = {}

	for player in data["partidas"]:
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
		"player_win_rate": (player_wins *1.0/ total_tiradas)*100 if total_tiradas > 0 else 0,
		"ia_win_rate": (ia_wins *1.0/ total_tiradas)*100 if total_tiradas > 0 else 0,
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
	var total_tokens = {"psicológico": 0, "verbal": 0, "ciberbullying": 0, "exclusión_social": 0,"físico": 0,"sexual": 0}
	var bullying_related_cards = {}

	for player in data["partidas"]:
		for partida in player["partidas"]:
			for tirada in partida["tiradas"]:
				for token in tirada["token_jugador"]:
					total_tokens[token] += tirada["token_jugador"][token]

				var card = tirada["carta_bu"]["nombre"]
				if not bullying_related_cards.has(card):
					bullying_related_cards[card] = 0
				bullying_related_cards[card] += 1

	return {
		"token_analysis": total_tokens,
		"bullying_card_frequency": bullying_related_cards
	}
