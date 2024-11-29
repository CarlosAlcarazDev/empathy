# ===============================
# Nombre del Script: game_manager.gd
# Desarrollador: Carlos Alcaraz Benítez
# Fecha de Creación: 14 de Noviembre de 2024
# Descripción: Este script maneja la lógica de las partida
# Encargado de gestionar los turnos, las acciones tanto del jugador como de la ia.
# Mostrar ventana modal con la información de las cartas seleccionadas por el jugador y la IA
# Repartir cartas a los jugadores una vez reiniciado el turno
# Mostrar nueva carta BU
# Finalizar juego cuando se acaban las cartas de BU
# ===============================
# Listado de funciones
#	_ready(): Función que se ejecuta al inicializar el nodo game_manager
#	_process(delta): Función que se ejecuta continuamente para manejar la lógica en cada frame
#	handle_countdown(delta): Manejar la cuenta atrás del turno
#	_on_sync_timer_timeout(): Función para manejar el temporizador de sincronización
#	change_state(new_state): Función para cambiar el estado del juego
#	prepare_game(): Función para preparar el juego inicial
#	start_turn(): Función para manejar el turno del jugador
#	check_game_result(): Función para verificar el resultado del turno
#	game_over(): Función cuando el juego termine
#	choose_ia_cards(): Función para elegir las cartas de la IA de forma aleatoria (IA PRIMITIVA, IA ALUMNO)
#	reset_turn_state(): Función para reiniciar el estado del turno
#	auto_select_player_cards(): Función para seleccionar cartas automáticamente para el jugador
#	auto_select_ia_cards(): Función para seleccionar cartas automáticamente para la IA
#	replenish_cards(): Función para reabastecer cartas al jugador y a la IA	
#	remove_selected_cards(): Función para eliminar las cartas seleccionadas del turno actual
#	update_bullying_card(): Función para actualizar la carta de bullying en cada turno
#	_on_ready_texture_button_pressed(): Función para manejar el evento del botón "aceptar" DEPRECATED
#	_on_ready_button_pressed(): Función para manejar el evento del botón "aceptar"
#	_on_continue_button_pressed(): Señal que se activa al presionar botón "Continuar"
#	_on_card_chosen_re(card_id): Función para manejar la selección de cartas tipo RE por el jugador
#	_on_card_chosen_hs(card_id): Función para manejar la selección de cartas tipo HS por el jugador
#	display_card_re(card: CardsRE, card_node: Control, is_reverse: bool): Función para actualizar la interfaz con los datos de la carta de tipo RE
#	display_card_hs(card: CardsHS, card_node: Control, is_reverse: bool): Función para actualizar la interfaz con los datos de la carta de tipo HS
#	display_card_bu(card: CardsBU, card_node: Control, is_reverse: bool): Función para actualizar la interfaz con los datos de la carta de bullying
#	disable_card_interaction(): Función para deshabilitar la interacción con las cartas del jugador
#	enable_card_interaction(): Función para habilitar la interacción con las cartas del jugador		
#	get_current_state() -> GameState: Función de consulta del estado del juego
#	has_player_chosen() -> bool: Función para saber si el jugador ha elegido cartas
#	has_ia_chosen() -> bool: Función para saber si la IA ha elegido cartas
#	_on_reverse_anverse_toggled(showing_reverses: bool): Maneja la señal y actualiza la visualización de las cartas
# ===============================
# 22/11/2024 Refactorizar check_game_result()




extends Control

# Estados del juego
enum GameState {
	PREPARE, 		# Preparación inicial del juego
	TURN,			# Turno simultáneo del jugador y la IA
	CHECK_RESULT,	# Comprobación de resultados al final del turno
	PAUSED,			# Juego pausado
	GAME_OVER		# Fin del juego
}

#Estado actual del juego al iniciar la partida
var current_state = GameState.PREPARE

# Referencias a nodos de la interfaz y del juego

@onready var deck_manager = $"../DeckManager"
@onready var deck_player = $"../DeckManager/DeckPlayer"
@onready var deck_ia = $"../DeckManager/DeckIA"
@onready var re_card_1 = $"../DeckManager/DeckPlayer/RECard1"
@onready var re_card_2 = $"../DeckManager/DeckPlayer/RECard2"
@onready var re_card_3 = $"../DeckManager/DeckPlayer/RECard3"
@onready var hs_card_1 = $"../DeckManager/DeckPlayer/HSCard1"
@onready var hs_card_2 = $"../DeckManager/DeckPlayer/HSCard2"
@onready var hs_card_3 = $"../DeckManager/DeckPlayer/HSCard3"
@onready var deck_bullying = $"../DeckManager/DeckBullying"
@onready var bullying_card = $"../DeckManager/DeckBullying/BullyingCard"
@onready var ready_texture_button = $"../UI/ReadyTextureButton"

# Constantes para los tiempos de cuenta atrás
const COUNTDOWN_30_SECONDS = 4 * 60  # En segundos (5 minutos) 
const COUNTDOWN_20_MINUTES = 2 * 60  # En segundos (25 minutos)

# Variables de tiempo
var countdown_30_seconds = COUNTDOWN_30_SECONDS # Temporizador de turno
var countdown_20_minutes = COUNTDOWN_20_MINUTES # Temporizador de partida global
# Flag para controlar el sonido de cuenta regresiva, aseguramos que suena una vez
var countdown_sound_playing = false  

# Referencias adicionales de la interfaz

@onready var countdown_30_seconds_label = $"../UI/CountdownTurn/Panel/Countdown30SecondsLabel"

@onready var beep_countdown_audio_stream_player = $"../UI/BeepCountdownAudioStreamPlayer"

@onready var countdown_20_minutes_label = $"../UI/CountdownTotal/Panel/Countdown20MinutesLabel"

@onready var end_turn_popup = $"../UI/EndTurnPopup"

@onready var continue_button = $"../UI/EndTurnPopup/ContinueButton"



@onready var bullying_label = $"../UI/EndTurnPopup/VBoxContainer/BullyingLabel"
@onready var name_type_bullying_label = $"../UI/EndTurnPopup/VBoxContainer/NameTypeBullyingLabel"
@onready var needs_bullying_label = $"../UI/EndTurnPopup/VBoxContainer/NeedsBullyingLabel"
@onready var player_label = $"../UI/EndTurnPopup/VBoxContainer/PlayerLabel"
@onready var name_re_label = $"../UI/EndTurnPopup/VBoxContainer/HBoxContainer/NameRELabel"

@onready var name_hs_label = $"../UI/EndTurnPopup/VBoxContainer/HBoxContainer2/NameHSLabel"
@onready var points_hs_label = $"../UI/EndTurnPopup/VBoxContainer/HBoxContainer2/PointsHSLabel"
@onready var ia_label = $"../UI/EndTurnPopup/VBoxContainer/IALabel"
@onready var ia_name_re_label = $"../UI/EndTurnPopup/VBoxContainer/HBoxContainer3/IANameRELabel"
@onready var ia_points_re_label = $"../UI/EndTurnPopup/VBoxContainer/HBoxContainer3/IAPointsRELabel"
@onready var ia_name_hs_label = $"../UI/EndTurnPopup/VBoxContainer/HBoxContainer4/IANameHSLabel"
@onready var ia_points_hs_label = $"../UI/EndTurnPopup/VBoxContainer/HBoxContainer4/IAPointsHSLabel"
@onready var total_points_player_label = $"../UI/EndTurnPopup/VBoxContainer/HBoxContainer5/TotalPointsPlayerLabel"
@onready var total_points_ia_label = $"../UI/EndTurnPopup/VBoxContainer/HBoxContainer6/TotalPointsIALabel"

@onready var ui = $"../UI"
@onready var blur_overlay = $"../UI/Overlay/BlurOverlay"
@onready var ready_button = $"../ReadyButton"

@onready var iare_card = $"../DeckManager/DeckIA/IARECard"
@onready var iahs_card = $"../DeckManager/DeckIA/IAHSCard"


@onready var ia_score_label = $"../UI/ScoreTokenIA/ShowScoreIA/IAScoreLabel"


@onready var ia_name_label = $"../UI/ScoreTokenIA/IANameLabel"



@onready var combo_label = $"../UI/ScoreTokenPlayer/ShowScorePlayer/ComboLabel"


@onready var combo_label_ia = $"../UI/ScoreTokenIA/ShowScoreIA/ComboLabel"

@onready var player_score_label = $"../UI/ScoreTokenPlayer/ShowScorePlayer/PlayerScorelabel"



@onready var correct_strategy_why_label = $"../UI/EndTurnPopup/VBoxContainer/CorrectStrategyWhyLabel"
@onready var game_over_control = $"../UI/GameOver"




@onready var new_game_option_window = $"../UI/NewGameOptionWindow"
@onready var beep_audio_stream_player = $"../UI/BeepAudioStreamPlayer"

@onready var audio_stream_player = $"../UI/AudioStreamPlayer"
@onready var game_result_texture_rect = $"../UI/GameOver/GameResultTextureRect"
@onready var game_result_label = $"../UI/GameOver/GameResultTextureRect/GameResultLabel"

@onready var score_token_ia = $"../UI/GameOver/GameResultTextureRect/ScoreTokenIA"
@onready var score_token_player = $"../UI/GameOver/GameResultTextureRect/ScoreTokenPlayer"
@onready var vs_label = $"../UI/GameOver/GameResultTextureRect/VSLabel"

@onready var game_over_player_scorelabel = $"../UI/GameOver/GameResultTextureRect/ScoreTokenPlayer/ShowScorePlayer/PlayerScorelabel"
@onready var game_over_ia_score_label = $"../UI/GameOver/GameResultTextureRect/ScoreTokenIA/ShowScoreIA/IAScoreLabel"

@onready var game_over_ia_name_label = $"../UI/GameOver/GameResultTextureRect/ScoreTokenIA/IANameLabel"
@onready var game_over_ia_combo_label = $"../UI/GameOver/GameResultTextureRect/ScoreTokenIA/ShowScoreIA/ComboLabel"

@onready var game_over_player_name_label = $"../UI/GameOver/GameResultTextureRect/ScoreTokenPlayer/PlayerNameLabel"
@onready var game_over_player_combo_label = $"../UI/GameOver/GameResultTextureRect/ScoreTokenPlayer/ShowScorePlayer/ComboLabel"

@onready var exclusion_social_token = $"../UI/ScoreTokenPlayer/ExclusionSocialToken"
@onready var fisico_token = $"../UI/ScoreTokenPlayer/FisicoToken"
@onready var psicologico_token = $"../UI/ScoreTokenPlayer/PsicologicoToken"
@onready var sexual_token = $"../UI/ScoreTokenPlayer/SexualToken"
@onready var verbal_token = $"../UI/ScoreTokenPlayer/VerbalToken"
@onready var ciberbullying_token = $"../UI/ScoreTokenPlayer/CiberbullyingToken"

@onready var exclusion_social_token_ia = $"../UI/ScoreTokenIA/ExclusionSocialToken"
@onready var fisico_token_ia = $"../UI/ScoreTokenIA/FisicoToken"
@onready var psicologico_token_ia = $"../UI/ScoreTokenIA/PsicologicoToken"
@onready var sexual_token_ia = $"../UI/ScoreTokenIA/SexualToken"
@onready var verbal_token_ia = $"../UI/ScoreTokenIA/VerbalToken"
@onready var ciberbullying_token_ia = $"../UI/ScoreTokenIA/CiberbullyingToken"



@onready var audio_stream_token = $"../UI/AudioStreamToken"
@onready var subtitles_label = $"../UI/SubtitlesControl/Panel/SubtitlesLabel"
@onready var subtitles_control = $"../UI/SubtitlesControl"
@onready var stats_bu = $"../DeckManager/DeckBullying/BullyingCard/StatsBu"
@onready var empathy_texture_rect = $"../DeckManager/DeckBullying/BullyingCard/StatsBu/EmpathyTextureRect"
@onready var emotional_support_texture_rect = $"../DeckManager/DeckBullying/BullyingCard/StatsBu/EmotionalSupportTextureRect"
@onready var intervention_texture_rect = $"../DeckManager/DeckBullying/BullyingCard/StatsBu/InterventionTextureRect"
@onready var comunication_texture_rect = $"../DeckManager/DeckBullying/BullyingCard/StatsBu/ComunicationTextureRect"
@onready var conflict_resolution_texture_rect = $"../DeckManager/DeckBullying/BullyingCard/StatsBu/ConflictResolutionTextureRect"

@onready var exclusion_combo_health = $"../UI/ScoreTokenPlayer/ExclusionSocialToken/ComboHealth"
@onready var fisic_combo_health = $"../UI/ScoreTokenPlayer/FisicoToken/ComboHealth"
@onready var psicologic_combo_health = $"../UI/ScoreTokenPlayer/PsicologicoToken/ComboHealth"
@onready var sexual_combo_health = $"../UI/ScoreTokenPlayer/SexualToken/ComboHealth"
@onready var verbal_combo_health = $"../UI/ScoreTokenPlayer/VerbalToken/ComboHealth"
@onready var ciber_combo_health = $"../UI/ScoreTokenPlayer/CiberbullyingToken/ComboHealth"

@onready var exclusion_combo_health_ia = $"../UI/ScoreTokenIA/ExclusionSocialToken/ComboHealth"
@onready var fisic_combo_health_ia = $"../UI/ScoreTokenIA/FisicoToken/ComboHealth"
@onready var psicologic_combo_health_ia = $"../UI/ScoreTokenIA/PsicologicoToken/ComboHealth"
@onready var sexual_combo_health_ia = $"../UI/ScoreTokenIA/SexualToken/ComboHealth"
@onready var verbal_combo_health_ia = $"../UI/ScoreTokenIA/VerbalToken/ComboHealth"
@onready var ciber_combo_health_ia = $"../UI/ScoreTokenIA/CiberbullyingToken/ComboHealth"



# Diccionario con las nuevas texturas para los tokens
var token_textures: Dictionary = {
	"exclusión_social": preload("res://assets/ui/tokens/token_exclusión_social.png"),
	"físico": preload("res://assets/ui/tokens/token_físico.png"),
	"psicológico": preload("res://assets/ui/tokens/token_psicologico.png"),
	"sexual": preload("res://assets/ui/tokens/token_sexual.png"),
	"verbal": preload("res://assets/ui/tokens/token_verbal.png"),
	"ciberbullying": preload("res://assets/ui/tokens/token_ciberbullying.png")
}


# Flag para controlar si jugador/IA han elegido cartas
var player_chosen = false
var ia_chosen = false
var ia_chosen_re = false
var ia_chosen_hs = false

# Almacenar las cartas elegidas por el jugador y la IA
var player_selected_card_re = null
var player_selected_card_hs = null
var ia_selected_card_re = null
var ia_selected_card_hs = null

# Listas de cartas del jugador y la IA
var player_cards_re = [] 	# Cartas del jugador tipo RE
var player_cards_hs = []	# Cartas del jugador tipo HS
var ai_cards_re = []		# Cartas de la IA tipo RE
var ai_cards_hs = []		# Cartas de la IA tipo HS
var card_bullying 			# Carta actual de situación de bullying

#Señales para sincronización de eventos
signal state_changed(new_state)
signal player_chosen_card(card_id)
signal ia_chosen_card(card_id)
signal countdown_finished()
signal ready_to_check_result()
signal card_chosen_re(card_id)
signal card_chosen_hs(card_id)

#Variable guardar combos
var combo_player = 0
var combo_ia = 0

# Diccionario con reglas de tokens
var token_rules: Dictionary = {
	"sexual": {"max_tokens": 2, "combos_per_token": 1},
	"verbal": {"max_tokens": 4, "combos_per_token": 4},
	"físico": {"max_tokens": 2, "combos_per_token": 4},
	"ciberbullying": {"max_tokens": 2, "combos_per_token": 3},
	"psicológico": {"max_tokens": 2, "combos_per_token": 5},
	"exclusión_social": {"max_tokens": 2, "combos_per_token": 4}
}
# Diccionario con los nodos de los tokens
var token_nodes: Dictionary = {}
var token_nodes_ia: Dictionary = {}

# Mapear el progreso de combos a las texturas correspondientes
var combo_health_textures: Dictionary = {
	1: preload("res://assets/ui/icons/combo_health_1.png"),
	2: preload("res://assets/ui/icons/combo_health_2.png"),
	3: preload("res://assets/ui/icons/combo_health_3.png"),
	4: preload("res://assets/ui/icons/combo_health_4.png"),
	5: preload("res://assets/ui/icons/combo_health_5.png"),
	6: preload("res://assets/ui/icons/combo_health_6.png"),
	7: preload("res://assets/ui/icons/combo_health_7.png"),
	8: preload("res://assets/ui/icons/combo_health_8.png"),
	9: preload("res://assets/ui/icons/combo_health_9.png"),
	10: preload("res://assets/ui/icons/combo_health_10.png")
}


var sync_timer = Timer.new()


const JSON_CORRECT_STRATEGY_PATH = "res://data/correct_strategy.json"
		


###############################################################################
###############################################################################
#                    INICIALIZACIÓN Y CONFIGURACIÓN                           #
###############################################################################
###############################################################################

# Función que se ejecuta al inicializar el nodo game_manager
func _ready():
	
	randomize() #Asegura que se inicie el generados de numeros aleatorios
	GlobalData.token_earned_ia["verbal"] = 0
	GlobalData.token_earned_ia["exclusión_social"] = 0
	GlobalData.token_earned_ia["psicológico"] = 0
	GlobalData.token_earned_ia["físico"] = 0
	GlobalData.token_earned_ia["sexual"] = 0
	GlobalData.token_earned_ia["ciberbullying"] = 0
	GlobalData.token_earned_player["verbal"] = 0
	GlobalData.token_earned_player["exclusión_social"] = 0
	GlobalData.token_earned_player["psicológico"] = 0
	GlobalData.token_earned_player["físico"] = 0
	GlobalData.token_earned_player["sexual"] = 0
	GlobalData.token_earned_player["ciberbullying"] = 0
	GlobalData.token_combos_ia["verbal"] = 0
	GlobalData.token_combos_ia["exclusión_social"] = 0
	GlobalData.token_combos_ia["psicológico"] = 0
	GlobalData.token_combos_ia["físico"] = 0
	GlobalData.token_combos_ia["sexual"] = 0
	GlobalData.token_combos_ia["ciberbullying"] = 0
	GlobalData.token_combos_player["verbal"] = 0
	GlobalData.token_combos_player["exclusión_social"] = 0
	GlobalData.token_combos_player["psicológico"] = 0
	GlobalData.token_combos_player["físico"] = 0
	GlobalData.token_combos_player["sexual"] = 0
	GlobalData.token_combos_player["ciberbullying"] = 0
	
	update_token_textures()
	# Configurar el volumen del sonido
	var volume_db = lerp(-80, 0, GameConfig.sfx_volume / 100.0)
	beep_countdown_audio_stream_player.volume_db = volume_db
	beep_audio_stream_player.volume_db = volume_db
	audio_stream_token.volume_db = volume_db
	# Cambia el estado inicial a "PREPARE"
	change_state(GameState.PREPARE)
	
	# Temporizador para sincronización regular del estado del juego
	
	sync_timer.set_wait_time(1.0) 
	sync_timer.set_one_shot(false)
	sync_timer.connect("timeout", Callable(self, "_on_sync_timer_timeout"))
	add_child(sync_timer)
	sync_timer.start()
	
	# Conectar señales para manejar la elección de cartas
	re_card_1.connect("card_chosen_re", Callable(self, "_on_card_chosen_re"))
	re_card_2.connect("card_chosen_re", Callable(self, "_on_card_chosen_re"))
	re_card_3.connect("card_chosen_re", Callable(self, "_on_card_chosen_re"))
	hs_card_1.connect("card_chosen_hs", Callable(self, "_on_card_chosen_hs"))
	hs_card_2.connect("card_chosen_hs", Callable(self, "_on_card_chosen_hs"))
	hs_card_3.connect("card_chosen_hs", Callable(self, "_on_card_chosen_hs"))
	
	#Conecta la señal para manejar el reverso o anverso de las cartas
	ui.connect("reverse_anverse_toggled", Callable(self, "_on_reverse_anverse_toggled"))
	
	
	
# Función que se ejecuta continuamente para manejar la lógica en cada frame
func _process(delta):
	if current_state == GameState.TURN:
		# Manejar la cuenta atrás del turno
		handle_countdown(delta)
		# Si ambos (jugador y IA) han elegido sus cartas, cambia al siguiente estado
		if player_chosen and ia_chosen:
			emit_signal("ready_to_check_result")
			change_state(GameState.CHECK_RESULT)

# Manejar la cuenta atrás del turno
func handle_countdown(delta):
	# Movido a _on_sync_timer_timeout
	#if countdown_20_minutes > 0:
		#countdown_20_minutes -= delta
		#countdown_20_minutes_label.text = "%d:%02d" % [int(countdown_20_minutes) / 60, int(countdown_20_minutes) % 60]

	if countdown_30_seconds > 0:
		countdown_30_seconds -= delta
		# Actualizar la UI dependiendo del tiempo restante. Mostrar "Aceptar" cuando queden más de 10 segundos
		if countdown_30_seconds > 10:
			ready_button.text = "Aceptar"
			countdown_30_seconds_label.text = "%02d:%02d" % [int(countdown_30_seconds) / 60, int(countdown_30_seconds) % 60]

		else:
			# Mostrar la cuenta atrás cuando queden 10 segundos o menos
			countdown_30_seconds_label.text = "%02d:%02d" % [int(countdown_30_seconds) / 60, int(countdown_30_seconds) % 60]
			ready_button.text = "%d" % max(int(countdown_30_seconds), 0)
			# Empezar el sonido de cuenta regresiva cuando quedan 10 segundos
			if countdown_30_seconds <= 10 and not countdown_sound_playing and countdown_20_minutes > 10 :
				beep_countdown_audio_stream_player.play()  # Reproduce el sonido
				countdown_sound_playing = true
	else:
		emit_signal("countdown_finished")
		# Seleccionar cartas automáticamente si no se han seleccionado
		if player_selected_card_re == null or player_selected_card_hs == null:
			auto_select_player_cards()
		if ia_selected_card_re == null or ia_selected_card_hs == null:
			auto_select_ia_cards()
		play_beep_sound("res://assets/audio/sfx/traimory-whoosh-hit-the-box-cinematic-trailer-sound-effects-193411.ogg")
		if new_game_option_window.visible == true:
			new_game_option_window.visible = false
		# Mover al siguiente estado
		change_state(GameState.CHECK_RESULT)
	# Actualizar el contador global de 20 minutos

# Función para manejar el temporizador de sincronización
func _on_sync_timer_timeout():
	# Imprimir estado actual del juego (Depuración)
	print("Estado actual del juego: ", current_state)
	if countdown_20_minutes > 0:
		countdown_20_minutes -= 1
		countdown_20_minutes_label.text = "%d:%02d" % [int(countdown_20_minutes) / 60, int(countdown_20_minutes) % 60]
				# Reproducir el sonido cuando el temporizador llega a 10
		if countdown_20_minutes == 10:
			print("Reproduciendo beep_countdown porque quedan 10 segundos.")
			if beep_countdown_audio_stream_player:  # Asegúrate de que el nodo existe
				beep_countdown_audio_stream_player.stream = load("res://assets/audio/sfx/mega-horn-gloomiest-signer-cinematic-trailer-sound-effects-124762.ogg")
				beep_countdown_audio_stream_player.play()
	else:
		print("Tiempo Global Terminado")
		GlobalData.game_over_time_or_bu = true
		change_state(GameState.GAME_OVER)
		if sync_timer:
			print("parar temporizador de sincronizacion")
			sync_timer.stop()


###############################################################################
###############################################################################
#                           GESTIÓN DE ESTADOS                                #
###############################################################################
###############################################################################

# Función para cambiar el estado del juego
func change_state(new_state):
	current_state = new_state
	emit_signal("state_changed", current_state) #Emite señal de cambio de estado
	match current_state:
		GameState.PREPARE:
			prepare_game()
		GameState.TURN:
			start_turn()
		GameState.CHECK_RESULT:
			check_game_result()
		GameState.GAME_OVER:
			game_over()

# Función para preparar el juego inicial
func prepare_game():
	print("Preparando el juego...")
	
	# Cargar y barajar las cartas iniciales al jugador y a la IA y crear listas
	deck_manager.load_cards_bu_from_json()
	deck_manager.load_cards_hs_from_json()
	deck_manager.load_cards_re_from_json()
	deck_manager.shuffle_deck_bu()
	deck_manager.shuffle_deck_re()
	deck_manager.shuffle_deck_hs()
	print("tamaño del_manager_cartas_re", deck_manager.deck_re.size())

	# Inicializar las listas de cartas del jugador (3 de cada tipo)
	player_cards_re = [
		deck_manager.deck_re.pop_back(),
		deck_manager.deck_re.pop_back(),
		deck_manager.deck_re.pop_back()
	]
	player_cards_hs = [
		deck_manager.deck_hs.pop_back(),
		deck_manager.deck_hs.pop_back(),
		deck_manager.deck_hs.pop_back()
	]
	
	# Mostrar las cartas del jugador en la interfaz con tres parámetros, 
	display_card_re(player_cards_re[0], re_card_1, GlobalData.showing_reverses)
	display_card_re(player_cards_re[1], re_card_2, GlobalData.showing_reverses)
	display_card_re(player_cards_re[2], re_card_3, GlobalData.showing_reverses)
	display_card_hs(player_cards_hs[0], hs_card_1, GlobalData.showing_reverses)
	display_card_hs(player_cards_hs[1], hs_card_2, GlobalData.showing_reverses)
	display_card_hs(player_cards_hs[2], hs_card_3, GlobalData.showing_reverses)

	# Actualizar la carta de bullying inicial
	update_bullying_card()
	display_card_bu(card_bullying, bullying_card, GlobalData.showing_reverses)
		
	# Inicializar las cartas de la IA
	ai_cards_re = [
		deck_manager.deck_re.pop_back() as CardsRE,
		deck_manager.deck_re.pop_back() as CardsRE,
		deck_manager.deck_re.pop_back() as CardsRE
	]
	ai_cards_hs = [
		deck_manager.deck_hs.pop_back() as CardsHS,
		deck_manager.deck_hs.pop_back() as CardsHS,
		deck_manager.deck_hs.pop_back() as CardsHS
	]
	
	# Cambiar al estado de turno
	change_state(GameState.TURN)

# Función para manejar el turno del jugador
func start_turn():
	update_token_textures()
	print("Turno del jugador y la IA.")
	# Reiniciar los estados del turno
	reset_turn_state()
	# Actualizar la carta de bullying
	update_bullying_card() 
	# La IA selecciona automaticamente sus cartas 
	choose_ia_cards()
	
# Función para verificar el resultado del turno
# Refactorización de la función `check_game_result` 22/11/2024
func check_game_result():
	# Actualiza la información del bullying en las etiquetas
	update_bullying_info()
	
	# Obtiene las cartas seleccionadas
	var player_re_card = get_player_card_re()
	var player_hs_card = get_player_card_hs()
	var ia_re_card = deck_manager.get_card_re_by_id(int(ia_selected_card_re))
	var ia_hs_card = deck_manager.get_card_hs_by_id(int(ia_selected_card_hs))
	var player_bullying_card = deck_manager.get_card_bu_by_id(card_bullying.id_carta)
	
	# Verifica combinación válida
	var combination_result = check_valid_combination(player_bullying_card, player_re_card, player_hs_card)
	var valid_combination = combination_result[0]
	var raw_match = combination_result[1]
	var combination_result_ia = check_valid_combination(player_bullying_card, ia_re_card, ia_hs_card)
	var valid_combination_ia = combination_result_ia[0]
	
	
	# Calcula puntuaciones
	# Actualiza las etiquetas del jugador y la IA
	var player_score = calculate_player_score(player_bullying_card, player_re_card, player_hs_card, valid_combination)
	update_player_labels(player_score, valid_combination, raw_match, player_re_card, player_hs_card)
	var ia_score = calculate_ia_score(player_bullying_card, ia_re_card, ia_hs_card, valid_combination_ia)
	#var ia_score = calculate_score(player_bullying_card, ia_re_card, ia_hs_card)
	print("total score: player_score: ", player_score)
	print("total score: ia_score: ", ia_score)
	#var ia_score =100
	#update_ia_labels(ia_score, ia_re_card, ia_hs_card)
	if !valid_combination:
		correct_strategy_why_label.text = str(player_score) + " puntos total turno"
	
	# Actualizar las puntuaciones totales y el combo
	update_total_scores(player_score, ia_score)
	update_combo(player_score, valid_combination)
	update_combo_ia(ia_score, valid_combination_ia)
	
	# Finalizar el turno
	end_turn_actions()


# Actualiza información sobre el bullying
func update_bullying_info():
	bullying_label.text = "Situación de acoso de tipo " + card_bullying.tipo
	name_type_bullying_label.text = card_bullying.nombre

# Obtiene la carta de respuesta empática seleccionada por el jugador
func get_player_card_re():
	if int(player_selected_card_re) != -1:
		return deck_manager.get_card_re_by_id(int(player_selected_card_re))
	return null

# Obtiene la carta de habilidad social seleccionada por el jugador
func get_player_card_hs():
	if int(player_selected_card_hs) != -1:
		return deck_manager.get_card_hs_by_id(int(player_selected_card_hs))
	return null

func check_valid_combination(player_bullying_card, player_re_card, player_hs_card):
	var json_correct = load_strategy(JSON_CORRECT_STRATEGY_PATH)
	if json_correct and player_re_card and player_hs_card:
		var match = find_combination(json_correct, player_bullying_card.id_carta, int(player_selected_card_re), int(player_selected_card_hs))
		if match.size() > 0 and match.has("por_que"):
			print("¡La combinación de cartas está en las combinaciones correctas!")
			print("Razón: ", match["por_que"])
			return [true, match]  # Devolver un Array con los resultados
		elif match.size() > 0:
			print("¡Combinación encontrada, pero falta la clave 'por_que'!")
	print("No se encontró ninguna combinación.")
	return [false, null]  # Devolver un Array con valores predeterminados

# Calcula la puntuación del jugador
func calculate_player_score(player_bullying_card, player_re_card, player_hs_card, valid_combination):
	if valid_combination:
		return 1500
	# Inicializa una variable para almacenar la puntuación
	var score = 0

	# Calcula la puntuación según las cartas seleccionadas
	if player_re_card or player_hs_card:
		score = calculate_score(player_bullying_card, player_re_card, player_hs_card)

	return score
# Calcula la puntuación de la ia
func calculate_ia_score(player_bullying_card, ia_re_card, ia_hs_card, valid_combination_ia):
	if valid_combination_ia:
		return 1500
	# Inicializa una variable para almacenar la puntuación
	var score = 0

	# Calcula la puntuación según las cartas seleccionadas
	if ia_re_card or ia_hs_card:
		score = calculate_score(player_bullying_card, ia_re_card, ia_hs_card)

	return score


# Actualiza las etiquetas del jugador
func update_player_labels(player_score, valid_combination, raw_match, player_re_card, player_hs_card):
	
	player_label.text = GlobalData.user
	if player_re_card:
		var player_bullying_card = deck_manager.get_card_bu_by_id(card_bullying.id_carta)
		#name_re_label.text = player_re_card.nombre #+ " Multiplicador " + str(get_affinity_multiplier(player_re_card.afinidad, player_bullying_card.tipo))
		name_re_label.text = player_re_card.nombre + " - Factor Afinidad x" + str(GlobalData.re_multiplier) + " - Puntuación: " + str(GlobalData.re_total_score)
	else:
		name_re_label.text = "NO HAS ELEGIDO CARTA DE RESPUESTA EMPÁTICA"
	if player_hs_card:
		var player_bullying_card = deck_manager.get_card_bu_by_id(card_bullying.id_carta)
		#name_hs_label.text = player_hs_card.nombre # + " Multiplicador " + str(get_affinity_multiplier(player_hs_card.afinidad, player_bullying_card.tipo))
		name_hs_label.text = player_hs_card.nombre + " - Factor Afinidad x" + str(GlobalData.hs_multiplier) + " - Puntuación: " + str(GlobalData.hs_total_score)
	else:
		name_hs_label.text = "NO HAS ELEGIDO CARTA DE HABILIDAD SOCIAL"
	if valid_combination:
		player_label.text = GlobalData.user + " ¡COMBINACIÓN PERFECTA! +1500 PUNTOS"
		name_re_label.text = player_re_card.nombre
		name_hs_label.text = player_hs_card.nombre
		correct_strategy_why_label.text = raw_match["por_que"]
		#points_hs_label.text = str(200) + " puntos"
	elif player_score >= 600:
		player_label.text = GlobalData.user + " ¡PUNTUACIÓN SUPERIOR A 600 +1 COMBO!"
		#points_hs_label.text = str(player_score) + " puntos"
		
	
		

# Actualiza las etiquetas de la IA
func update_ia_labels(ia_score, ia_re_card, ia_hs_card):
	ia_name_re_label.text = ia_re_card.nombre
	ia_name_hs_label.text = ia_hs_card.nombre
	ia_points_hs_label.text = str(ia_score) + " puntos"

# Actualiza las puntuaciones totales
func update_total_scores(player_score, ia_score):
	GlobalData.total_player_score += player_score
	GlobalData.total_ia_score += ia_score
	#total_points_player_label.text = str(GlobalData.total_player_score) + " puntos"
	#total_points_ia_label.text = str(GlobalData.total_ia_score) + " puntos"
	player_score_label.text = str(GlobalData.total_player_score)
	ia_score_label.text = str(GlobalData.total_ia_score)
	

# Actualiza el combo según las reglas
func update_combo(player_score, valid_combination):
	print("normalice: ", normalize_bullying_type(card_bullying.tipo))
	if valid_combination or player_score >= 600:
		GlobalData.combo_player += 1
		# Incrementar en token_combos según el tipo de bullying
		var bullying_type = normalize_bullying_type(card_bullying.tipo)  # Obtener el tipo de bullying de la carta actual
		if GlobalData.token_combos_player.has(bullying_type):
			GlobalData.token_combos_player[bullying_type] += 1  # Sumar 1 al contador del tipo de bullying correspondiente
			# Verificar y otorgar tokens
			var current_combos = GlobalData.token_combos_player[bullying_type]
			check_and_award_tokens(bullying_type, current_combos)
			
	
	combo_label.text = str(GlobalData.combo_player)

# Actualiza el combo ia según las reglas
func update_combo_ia(ia_score, valid_combination):
	print("normalice: ", normalize_bullying_type(card_bullying.tipo))
	if valid_combination or ia_score >= 600:
		GlobalData.combo_ia += 1
		# Incrementar en token_combos según el tipo de bullying
		var bullying_type = normalize_bullying_type(card_bullying.tipo)  # Obtener el tipo de bullying de la carta actual
		if GlobalData.token_combos_ia.has(bullying_type):
			GlobalData.token_combos_ia[bullying_type] += 1  # Sumar 1 al contador del tipo de bullying correspondiente
	
			var current_combos = GlobalData.token_combos_ia[bullying_type]
			check_and_award_tokens_ia(bullying_type, current_combos)
			
	combo_label_ia.text = str(GlobalData.combo_ia)
	print("GlobalData.combo_ia", str(GlobalData.combo_ia))


# Verifica y otorga tokens según los combos realizados
func check_and_award_tokens(bullying_type: String, combo_count: int):
	if token_rules.has(normalize_bullying_type(bullying_type)):
		var rule = token_rules[normalize_bullying_type(bullying_type)]
		var max_tokens = rule["max_tokens"]
		var combos_per_token = rule["combos_per_token"]

		# Calcular cuántos tokens corresponden según los combos actuales
		var tokens_earned = min(combo_count / combos_per_token, max_tokens)
		
				# Guardar en la variable global los tokens ganados
		if GlobalData.token_earned_player.has(normalize_bullying_type(bullying_type)):
			GlobalData.token_earned_player[normalize_bullying_type(bullying_type)] = tokens_earned

# Verifica y otorga tokens según los combos realizados
func check_and_award_tokens_ia(bullying_type: String, combo_count: int):
	if token_rules.has(normalize_bullying_type(bullying_type)):
		var rule = token_rules[normalize_bullying_type(bullying_type)]
		var max_tokens = rule["max_tokens"]
		var combos_per_token = rule["combos_per_token"]

		# Calcular cuántos tokens corresponden según los combos actuales
		var tokens_earned = min(combo_count / combos_per_token, max_tokens)
		
				# Guardar en la variable global los tokens ganados
		if GlobalData.token_earned_ia.has(normalize_bullying_type(bullying_type)):
			GlobalData.token_earned_ia[normalize_bullying_type(bullying_type)] = tokens_earned

		
# Acciones al final del turno
func end_turn_actions():
	#ready_button.disabled = true
	#disable_card_interaction()
	blur_overlay.visible = true
	end_turn_popup.visible = true

	
	
#Función para calcular la puntuación total de un jugador o la IA
func calculate_score(bullying_card, re_card, hs_card) -> float:
	#Inicializamos las puntuaciones individuales
	var total_score: float = 0.0
	var attributes_count: float = 0
	
	# Variables para acumular puntuaciones específicas de RE y HS
	var re_total_score: float = 0.0
	var hs_total_score: float = 0.0

	# Cálculo para los atributos de RE
	if re_card != null:
		var re_multiplier = get_affinity_multiplier(re_card.afinidad, bullying_card.tipo)
		GlobalData.re_multiplier = re_multiplier
		var partial_score: float = 0.0
		print ("re_multiplier", re_multiplier)
		print ("bulling_card afinidad re ", re_card.afinidad, bullying_card.tipo)
		if bullying_card.empatia > 0:
			var empathy_score: float = 0.0
			empathy_score = round(float(min(re_card.empatia, bullying_card.empatia)) / float(bullying_card.empatia) * 10 * float(re_multiplier) * 10)
			re_total_score += empathy_score
			attributes_count += 1
			print("total:re_card.empatia ", str(re_card.empatia))
			print("total:bullying_card.empatia", str(bullying_card.empatia))
			print("total: " , empathy_score)
			print("total:  re_multiplier: ", str(re_multiplier))
		if bullying_card.apoyo_emocional > 0:
			var emotional_support_score: float = 0.0
			emotional_support_score = round((min(re_card.apoyo_emocional, bullying_card.apoyo_emocional) / float(bullying_card.apoyo_emocional)) * 10 * float(re_multiplier) * 10)
			re_total_score += emotional_support_score
			attributes_count += 1
			print("total:re_card.apoyo_emociona ", str(re_card.apoyo_emocional))
			print("total:bullying_card.apoyo_emocional", str(bullying_card.apoyo_emocional))
			print("total: " , emotional_support_score)
			print("total:  re_multiplier: ", str(re_multiplier))
		if bullying_card.intervencion > 0:
			var intervention_score: float = 0.0
			intervention_score = round((min(re_card.intervencion, bullying_card.intervencion) / float(bullying_card.intervencion)) * 10 * float(re_multiplier) * 10)
			re_total_score += intervention_score
			partial_score += partial_score
			print("total:re_card.intervencion ", str(re_card.intervencion))
			print("total:bullying_card.intervencion", str(bullying_card.intervencion))
			print("total: " , intervention_score)
			print("total:  re_multiplier: ", str(re_multiplier))
	
		# Mostrar en la etiqueta el nombre de la carta RE junto con su puntuación total
		#name_re_label.text = re_card.nombre + " - Factor Afinidad x" + str(re_multiplier) + " - Puntuación: " + str(re_total_score)

	# Cálculo para los atributos de HS
	if hs_card != null:
		var hs_multiplier = get_affinity_multiplier(hs_card.afinidad, bullying_card.tipo)
		GlobalData.hs_multiplier = hs_multiplier
		print ("bulling_card afinidad hs ", hs_card.afinidad, bullying_card.tipo)
		print ("hs_multiplier", hs_multiplier)
		if bullying_card.comunicacion > 0:
			var communication_score: float = 0.0
			communication_score = round((min(hs_card.comunicacion, bullying_card.comunicacion) / float(bullying_card.comunicacion)) * 10 * float(hs_multiplier) * 10)
			hs_total_score += communication_score
			attributes_count += 1
		if bullying_card.resolucion_de_conflictos > 0:
			var conflict_resolution_score: float = 0.0
			conflict_resolution_score = round((min(hs_card.resolucion_de_conflictos, bullying_card.resolucion_de_conflictos) / float(bullying_card.resolucion_de_conflictos)) * 10 * float(hs_multiplier) * 10)
			hs_total_score += conflict_resolution_score
			attributes_count += 1
	   # Mostrar en la etiqueta el nombre de la carta HS junto con su puntuación total
			#name_hs_label.text = hs_card.nombre + " - Factor Afinidad x" + str(hs_multiplier) + " - Puntuación: " + str(hs_total_score)
			print("name_hs_label.text = hs_card.nombre +  - Puntuación:  + str(hs_total_score)" + str(hs_total_score))

	# Agregar las puntuaciones de RE y HS al total general
	GlobalData.re_total_score = re_total_score
	GlobalData.hs_total_score = hs_total_score
	
	total_score += re_total_score
	total_score += hs_total_score
	print("total_score: "+  str(total_score))
	
	return total_score 
	
	
# Función auxiliar para calcular el multiplicador de afinidad
func get_affinity_multiplier(card_affinity: Dictionary, bullying_type: String) -> float:

	if card_affinity.has(bullying_type):
		match card_affinity[bullying_type]:
			"Alta":
				print("La carta utilizada tiene alta afinidad con el bullying de tipo ", bullying_type, ". Se multiplica por 1.5.")
				return 2
			"Media":
				print("La carta utilizada tiene afinidad media con el bullying de tipo ", bullying_type, ". Se multiplica por 1.")
				return 1.0
			"Baja":
				print("La carta utilizada tiene baja afinidad con el bullying de tipo ", bullying_type, ". Se multiplica por 0.5.")
				return 0.5
	print("La carta utilizada no tiene afinidad específica con el bullying de tipo ", bullying_type, ". Se multiplica por 1.")
	return 1.0  # Por defecto si no se encuentra la afinidad	
# Función para normalizar los nombres de tipos de bullying
func normalize_bullying_type(bullying_type: String) -> String:
	return bullying_type.to_lower().replace(" ", "_")

func game_over():
	print("GlobalData.tokens_earned")
	print(GlobalData.token_combos_player)
# {"verbal": 2, "exclusión_social": 1, "psicológico": 0, "físico": 3, "sexual": 0, "ciberbullying": 1}
	print("GlobalData.tokens_earned")
	print(GlobalData.token_combos_ia)
#	 {"verbal": 1, "exclusión_social": 0, "psicológico": 2, "físico": 2, "sexual": 1, "ciberbullying": 0}

	print("GlobalData.token_earned")
	print(GlobalData.token_earned_player)
	print("Juego Terminado.")
	# Verifica si el juego terminó por tiempo o condición especial
	if GlobalData.game_over_time_or_bu == true:
		var texture_path = ""
		beep_audio_stream_player.stop()
		beep_countdown_audio_stream_player.stop()
		score_token_ia.visible = true
		score_token_player.visible = true
		game_over_ia_name_label.text = GlobalData.get_difficulty_text(GameConfig.ia_difficulty)
		game_over_ia_combo_label.text = str(GlobalData.combo_ia)
		game_over_player_name_label.text = GlobalData.user
		game_over_player_combo_label.text = str(GlobalData.combo_player)
		game_over_player_scorelabel.text = str(GlobalData.total_player_score)
		game_over_ia_score_label.text = str(GlobalData.total_ia_score)
		score_token_player.get_node("ExclusionSocialToken/Panel/Label").text = str(GlobalData.token_earned_player["exclusión_social"])
		score_token_player.get_node("FisicoToken/Panel/Label").text = str(GlobalData.token_earned_player["físico"])
		score_token_player.get_node("PsicologicoToken/Panel/Label").text = str(GlobalData.token_earned_player["psicológico"])
		score_token_player.get_node("SexualToken/Panel/Label").text = str(GlobalData.token_earned_player["sexual"])
		score_token_player.get_node("VerbalToken/Panel/Label").text = str(GlobalData.token_earned_player["verbal"])
		score_token_player.get_node("CiberbullyingToken/Panel/Label").text = str(GlobalData.token_earned_player["ciberbullying"])
		
		score_token_ia.get_node("ExclusionSocialToken/Panel/Label").text = str(GlobalData.token_earned_ia["exclusión_social"])
		score_token_ia.get_node("FisicoToken/Panel/Label").text = str(GlobalData.token_earned_ia["físico"])
		score_token_ia.get_node("PsicologicoToken/Panel/Label").text = str(GlobalData.token_earned_ia["psicológico"])
		score_token_ia.get_node("SexualToken/Panel/Label").text = str(GlobalData.token_earned_ia["sexual"])
		score_token_ia.get_node("VerbalToken/Panel/Label").text = str(GlobalData.token_earned_ia["verbal"])
		score_token_ia.get_node("CiberbullyingToken/Panel/Label").text = str(GlobalData.token_earned_ia["ciberbullying"])
		
		update_token_textures_game_over()
		
		if GlobalData.total_player_score > GlobalData.total_ia_score:
			# Victoria
			print("time out: victoria")
			game_result_label.text = "VICTORIA"
			texture_path = "res://assets/ui/backgrounds/victory_2.png"
			score_token_ia.visible = true
			score_token_player.visible = true
			vs_label.visible = true
		elif GlobalData.total_player_score < GlobalData.total_ia_score:
			# Derrota
			print("time out: derrota")
			game_result_label.text = "DERROTA"
			texture_path = "res://assets/ui/backgrounds/defeat_1_borderless.png"
			score_token_ia.visible = true
			score_token_player.visible = true
			vs_label.visible = true
		else:
			# Empate
			print("time out: empate")
			game_result_label.text = "EMPATE"
			texture_path = "res://assets/ui/backgrounds/draw_1.png"  # Ruta a la textura de empate

		# Aplicar efectos visuales
		blur_overlay.visible = true
		var material = blur_overlay.material
		if material is ShaderMaterial:
			material.set_shader_parameter("darkness_factor", 0.05)
		audio_stream_player.stop()
		play_beep_sound("res://assets/audio/sfx/traimory-hit-low-gun-shot-cinematic-trailer-sound-effects-161154.mp3")
		game_over_control.visible = true

		# Asignar la textura al TextureRect dinámicamente
		var result_texture = load(texture_path)
		game_result_texture_rect.texture = result_texture
		game_result_texture_rect.visible = true

	else:
		# Si el juego terminó por abortar
		if GlobalData.game_over_abort == true:
			beep_audio_stream_player.stop()
			beep_countdown_audio_stream_player.stop()
			var texture_path = "res://assets/ui/backgrounds/defeat_1_borderless.png"
			print("Juego terminado por abandono")
			game_result_label.text = "ABANDONO"
			score_token_ia.visible = false
			score_token_player.visible = false
			vs_label.visible = false
			blur_overlay.visible = true
			var material = blur_overlay.material
			if material is ShaderMaterial:
				material.set_shader_parameter("darkness_factor", 0.05)
			audio_stream_player.stop()
			play_beep_sound("res://assets/audio/sfx/traimory-hit-low-gun-shot-cinematic-trailer-sound-effects-161154.mp3")
			game_over_control.visible = true

			# Asignar la textura al TextureRect dinámicamente
			var result_texture = load(texture_path)
			game_result_texture_rect.texture = result_texture
			game_result_texture_rect.visible = true


###############################################################################
###############################################################################
#                           TURNO DEL JUGADOR E IA                            #
###############################################################################
###############################################################################

# Función para elegir las cartas de la IA de forma aleatoria (IA PRIMITIVA, IA ALUMNO)
func choose_ia_cards():
	print("La IA está eligiendo sus cartas.")
#	Seleccionar cartas aleatorias de los mazos disponibles
	var random_index_re = randi() % ai_cards_re.size()
	var random_index_hs = randi() % ai_cards_hs.size()

	# Asignar las cartas seleccionadas
	ia_selected_card_re = ai_cards_re[random_index_re].id_carta
	ia_selected_card_hs = ai_cards_hs[random_index_hs].id_carta
	

	
	# Mostrar las cartas elegidas en la consola para verificar
	print("Carta RE seleccionada por la IA: ", ia_selected_card_re)
	print("Carta HS seleccionada por la IA: ", ia_selected_card_hs)
	var ia_re_card = deck_manager.get_card_re_by_id(int(ia_selected_card_re))
	var ia_hs_card = deck_manager.get_card_hs_by_id(int(ia_selected_card_hs))
	
	#Llamada para generar proceso aleatorio en la visualización de seleccion de cartas
	show_card_with_delay_re(iare_card, ia_re_card, GlobalData.showing_reverses)
	show_card_with_delay_hs(iahs_card, ia_hs_card, GlobalData.showing_reverses)
	
	# Marcar que la IA ha terminado de elegir sus cartas
	ia_chosen = true
	
	## Espera n segundos a mostrar la carta (simula pensamiento)
	#var random_delay_re = randf_range(1, 5)
	#await get_tree().create_timer(random_delay_re).timeout
	#iare_card.visible = true
	#display_ia_card_re(ia_re_card, iare_card, GlobalData.showing_reverses)
	#var random_delay_hs = randf_range(1, 5)
	#await get_tree().create_timer(random_delay_hs).timeout
	#iahs_card.visible = true
	#display_ia_card_hs(ia_hs_card, iahs_card, GlobalData.showing_reverses)
	
# Función para mostrar iare_card con un delay aleatorio
func show_card_with_delay_re(card_to_show, card_data, reverse_flag):
	async_show_card_re(card_to_show, card_data, reverse_flag)

# Función para mostrar iahs_card con un delay aleatorio
func show_card_with_delay_hs(card_to_show, card_data, reverse_flag):
	async_show_card_hs(card_to_show, card_data, reverse_flag)

# Corutina asíncrona para manejar el delay y mostrar iare_card
func async_show_card_re(card_to_show, card_data, reverse_flag):
	var random_delay_re = randf_range(1, 5)
	await get_tree().create_timer(random_delay_re).timeout
	play_beep_sound("res://assets/audio/sfx/seleccionar_carta.ogg")
	card_to_show.visible = true
	hide_random_cards(1)
	display_ia_card_re(card_data, card_to_show, reverse_flag)
	ia_chosen_re = true

# Corutina asíncrona para manejar el delay y mostrar iahs_card
func async_show_card_hs(card_to_show, card_data, reverse_flag):
	var random_delay_hs = randf_range(1, 5)
	await get_tree().create_timer(random_delay_hs).timeout
	play_beep_sound("res://assets/audio/sfx/seleccionar_carta.ogg")
	card_to_show.visible = true
	hide_random_cards(1)
	display_ia_card_hs(card_data, card_to_show, reverse_flag)
	ia_chosen_hs = true
# Función para seleccionar y ocultar aleatoriamente cartas
func hide_random_cards(num_to_hide):
	var all_cards = [
		deck_ia.get_node("AICard1"),
		deck_ia.get_node("AICard2"),
		deck_ia.get_node("AICard3"),
		deck_ia.get_node("AICard4"),
		deck_ia.get_node("AICard5"),
		deck_ia.get_node("AICard6")
	]
	var hidden_cards = []  # Lista para almacenar las cartas ocultas
	
# Seleccionar una carta aleatoria
	var selected_card = null
	while selected_card == null:
		var random_index = randi() % all_cards.size()
		var candidate_card = all_cards[random_index]
		if candidate_card.visible:
			selected_card = candidate_card
			all_cards.erase(candidate_card)  # Eliminar la carta seleccionada de la lista
		else:
			print(candidate_card.name, "ya está oculta, seleccionando otra.")

	# Ocultar la carta
	if selected_card:
		selected_card.visible = false
	
# Función para reiniciar el estado del turno
func reset_turn_state():
	# Habilitar el botón "Aceptar" y restablecer el contador de tiempo
	ready_button.disabled = false
	ready_button.visible = true
	countdown_30_seconds_label.text = "Aceptar" 
	countdown_30_seconds = COUNTDOWN_30_SECONDS
	ready_button.text = "Aceptar"
	countdown_sound_playing = false
	# No muestra la carta elegida
	iare_card.visible = false
	iahs_card.visible = false
	correct_strategy_why_label.text = ""
	
	#Restablece cartas IA
	for i in range(1, 7):  # Itera del 1 al 6
		deck_ia.get_node("AICard" + str(i)).visible = true
	
	# Restablecer flags y cartas seleccionadas
	player_chosen = false
	ia_chosen = false
	player_selected_card_hs = null
	player_selected_card_re = null
	ia_selected_card_re = null
	ia_selected_card_hs = null


###############################################################################
###############################################################################
#                           GESTIONAR MAZOS                                   #
###############################################################################
###############################################################################

# Función para seleccionar cartas automáticamente para el jugador
func auto_select_player_cards():
	print("No se seleccionó carta para el jugador, asignando -1.")
	if player_selected_card_re == null:
		player_selected_card_re = -1  # Marca especial para indicar que no se seleccionó carta
	if player_selected_card_hs == null:
		player_selected_card_hs = -1 # Marca especial para indicar que no se seleccionó carta

# Función para seleccionar cartas automáticamente para la IA
func auto_select_ia_cards():
	print("No se seleccionó carta para la IA, asignando -1.")
	if ia_selected_card_re == null:
		ia_selected_card_re = -1 # Marca especial para indicar que no se seleccionó carta
	if ia_selected_card_hs == null:
		ia_selected_card_hs = -1 # Marca especial para indicar que no se seleccionó carta
		
# Función para reabastecer cartas al jugador y a la IA	
func replenish_cards():
	# Borrar las cartas seleccionadas del turno anterior de las listas 
	remove_selected_cards()
	# Verificar y recargar mazos si es necesario (Listas con menos de 3 cartas)
	if deck_manager.deck_re.size() < 3:
		print("Recargando y barajando el mazo de cartas RE.")
		deck_manager.load_cards_re_from_json()
		deck_manager.shuffle_deck_re()
	if deck_manager.deck_hs.size() < 3:
		print("Recargando y barajando el mazo de cartas HS.")
		deck_manager.load_cards_hs_from_json()
		deck_manager.shuffle_deck_hs()
		
	# Reponer cartas al jugador y a la IA
	while player_cards_re.size() < 3 and deck_manager.deck_re.size() > 0:
		player_cards_re.append(deck_manager.deck_re.pop_back())
	while player_cards_hs.size() < 3 and deck_manager.deck_hs.size() > 0:
		player_cards_hs.append(deck_manager.deck_hs.pop_back())
	while ai_cards_re.size() < 3 and deck_manager.deck_re.size() > 0:
		ai_cards_re.append(deck_manager.deck_re.pop_back() as CardsRE)
	while ai_cards_hs.size() < 3 and deck_manager.deck_hs.size() > 0:
		ai_cards_hs.append(deck_manager.deck_hs.pop_back() as CardsHS)
	
	# Mostrar las nuevas cartas en la interfaz
	re_card_1.move_to_original_position()
	re_card_2.move_to_original_position()
	re_card_3.move_to_original_position()
	hs_card_1.move_to_original_position()
	hs_card_2.move_to_original_position()
	hs_card_3.move_to_original_position()
	display_card_re(player_cards_re[0], re_card_1, GlobalData.showing_reverses)
	display_card_re(player_cards_re[1], re_card_2, GlobalData.showing_reverses)
	display_card_re(player_cards_re[2], re_card_3, GlobalData.showing_reverses)
	display_card_hs(player_cards_hs[0], hs_card_1, GlobalData.showing_reverses)
	display_card_hs(player_cards_hs[1], hs_card_2, GlobalData.showing_reverses)
	display_card_hs(player_cards_hs[2], hs_card_3, GlobalData.showing_reverses)
	print("Cartas reabastecidas para el jugador y la IA.")

# Función para eliminar las cartas seleccionadas del turno actual
func remove_selected_cards():
	print("Eliminando cartas seleccionadas del jugador y la IA.")
	# Convertir `player_selected_card_re` y `player_selected_card_hs` a `int` si son cadenas
	var selected_re_id = int(player_selected_card_re) if typeof(player_selected_card_re) == TYPE_STRING else player_selected_card_re
	var selected_hs_id = int(player_selected_card_hs) if typeof(player_selected_card_hs) == TYPE_STRING else player_selected_card_hs

	# Buscar y eliminar las cartas seleccionadas del turno actual del jugador
	if selected_re_id != null:
		for card in player_cards_re:
			if card.id_carta == selected_re_id:
				player_cards_re.erase(card)
				break
	if selected_hs_id != null:
		for card in player_cards_hs:
			if card.id_carta == selected_hs_id:
				player_cards_hs.erase(card)
				break
	# Convertir `ia_selected_card_re` y `ia_selected_card_hs` a `int` si son cadenas
	var selected_ai_re_id = int(ia_selected_card_re) if typeof(ia_selected_card_re) == TYPE_STRING else ia_selected_card_re
	var selected_ai_hs_id = int(ia_selected_card_hs) if typeof(ia_selected_card_hs) == TYPE_STRING else ia_selected_card_hs

	# Buscar y eliminar las cartas seleccionadas del turno actual de la IA
	if selected_ai_re_id != null:
		for card in ai_cards_re:
			if card.id_carta == selected_ai_re_id:
				ai_cards_re.erase(card)
				break
	if selected_ai_hs_id != null:
		for card in ai_cards_hs:
			if card.id_carta == selected_ai_hs_id:
				ai_cards_hs.erase(card)
				break
	# Reiniciar las variables de cartas seleccionadas para el próximo turno
	player_selected_card_re = null
	player_selected_card_hs = null
	ia_selected_card_re = null
	ia_selected_card_hs = null

	print("Contenido de player_cards_re después de borrar:", player_cards_re)
	print("Contenido de player_cards_hs después de borrar:", player_cards_hs)

	# Reiniciar las variables de cartas seleccionadas para el próximo turno
	player_selected_card_re = null
	player_selected_card_hs = null
	ia_selected_card_re = null
	ia_selected_card_hs = null

# Función para actualizar la carta de bullying en cada turno
func update_bullying_card():
	# Verificar si todavía quedan cartas en el mazo de bullying
	if deck_manager.deck_bu.size() > 0:
		# Extraer la última carta del mazo y asignarla como la carta actual de bullying
		card_bullying = deck_manager.deck_bu.pop_back()
		# Actualizar la interfaz para mostrar la nueva carta de bullying
		display_card_bu(card_bullying, bullying_card, GlobalData.showing_reverses)
		print("Carta de bullying actualizada:", card_bullying.id_carta)
	else:
		# Si no hay cartas de bullying, finalizar el juego
		print("No quedan cartas de bullying. Terminando el juego.")
		GlobalData.game_over_time_or_bu = true
		change_state(GameState.GAME_OVER) # Cambia el estado del juego a "GAME_OVER"


###############################################################################
###############################################################################
#                           INTERACCIÓN DEL JUGADOR                           #
###############################################################################
###############################################################################

# Función para manejar el evento del botón "aceptar" DEPRECATED
func _on_ready_texture_button_pressed():
	if (player_selected_card_re == null or player_selected_card_hs == null):
		# Si el jugador no seleccionó cartas, asignarlas automáticamente
		auto_select_player_cards()
	
	# Detener el sonido de cuenta regresiva si está reproduciéndose
	if countdown_sound_playing:
		beep_countdown_audio_stream_player.stop()
		countdown_sound_playing = false  # Restablece flag
	
	#Finalizar la cuenta regresiva y desactivar el botón "aceptar"
	countdown_30_seconds = 0
	countdown_30_seconds_label.text = "OK"
	ready_button.text = "OK"
	ready_texture_button.disabled = true
	ready_texture_button.set_pressed(false)
	
	# Marcar que el jugador ha terminado su turno
	player_chosen = true
	#ia_chosen = false  # Simula que la IA también ha validado automáticamente
	
	# Desahabilitar la interacción en las cartas
	disable_card_interaction()
	
	# Emitir señal para que el juego continúe 
	emit_signal("ready_to_check_result")
	change_state(GameState.CHECK_RESULT)

# Función para manejar el evento del botón "aceptar"
func _on_ready_button_pressed():
	play_beep_sound("res://assets/audio/sfx/traimory-whoosh-hit-the-box-cinematic-trailer-sound-effects-193411.ogg")
	if (player_selected_card_re == null or player_selected_card_hs == null):
		# Si el jugador no seleccionó cartas, asignarlas automáticamente
		auto_select_player_cards()
	
	# Detener el sonido de cuenta regresiva si está reproduciéndose
	if countdown_sound_playing:
		beep_countdown_audio_stream_player.stop()
		countdown_sound_playing = false  # Restablece flag
	
	#Finalizar la cuenta regresiva y desactivar el botón "aceptar"
	countdown_30_seconds = 0
	countdown_30_seconds_label.text = "OK"
	ready_button.disabled = true
	#ready_button.set_pressed(false)
	
	# Marcar que el jugador ha terminado su turno
	player_chosen = true
	#ia_chosen = false  # Simula que la IA también ha validado automáticamente
	
	# Desahabilitar la interacción en las cartas
	disable_card_interaction()
	
	# Emitir señal para que el juego continúe 
	emit_signal("ready_to_check_result")
	change_state(GameState.CHECK_RESULT)

# Señal que se activa al presionar botón "Continuar"
func _on_continue_button_pressed():
	play_beep_sound("res://assets/audio/sfx/click.ogg")
	print("Iniciando el siguiente turno.")
	#Ocultar el modal y permitir interacción nuevamente
	ready_texture_button.disabled = false
	ready_texture_button.release_focus()  
	blur_overlay.visible = false
	end_turn_popup.visible = false
	enable_card_interaction()
	
	# Verifica si el juego debe terminar (tiempo finalizado o no hay más cartas en el mazo bu) o iniciar el siguiente turno
	if countdown_20_minutes <= 0 or deck_manager.deck_bu.size() == 0:
		GlobalData.game_over_time_or_bu = true
		change_state(GameState.GAME_OVER)
	else:
		replenish_cards()
		reset_turn_state()
		change_state(GameState.TURN)

# Función para manejar la selección de cartas tipo RE por el jugador
func _on_card_chosen_re(card_id):
	# Actualizar la carta seleccionada tipo RE del jugador
	player_selected_card_re = card_id
	
# Función para manejar la selección de cartas tipo HS por el jugador
func _on_card_chosen_hs(card_id):
	# Actualizar la carta seleccionada tipo HS del jugador
	player_selected_card_hs = card_id
		
		
###############################################################################
###############################################################################
#                              VISUALIZACIÓN                                  #
###############################################################################
###############################################################################

# Función para actualizar la interfaz con los datos de la carta de tipo RE
func display_card_re(card: CardsRE, card_node: Control, is_reverse: bool):
	# Obtener la referencia al nodo de la imagen de la carta
	var card_image_node = card_node.get_node("CardImage")
	# Construir la ruta a la imagen basándonos en el id de la carta
	var image_path = "res://assets/images/cards/re/" + str(card.id_carta) + "_RE.webp"
	# Cargar la imagen
	var texture = load(image_path)
	# Verificar si la textura fue cargada correctamente
	if texture:
		# Establecer la textura en el nodo `CardImage`
		card_image_node.texture = texture
	else:
		# Mostrar un mensaje de error si la imagen no se encuentra
		print("Error: No se pudo cargar la imagen en la ruta: ", image_path)

	# Actualiza los elementos de la UI en el nodo de la carta especificada	
	card_node.get_node("TitleCardLabel").text = card.nombre
	card_node.get_node("NumberCardLabel").text = str(card.id_carta)
	#card_node.get_node("TypeCardLabel").text = "Empatía: %d, Apoyo: %d, Intervención: %d" % [card.empatia, card.apoyo_emocional, card.intervencion]
	#card_node.get_node("DescriptionCardLabel").text = card.descripcion
	if GameConfig.game_mode == "Intuición":
		if is_reverse:
			print("is_reverse ", is_reverse)
			card_node.get_node("TypeCardLabel").text = "Contexto en el juego"
			card_node.get_node("DescriptionCardLabel").text = card.contexto_en_el_juego
		else:
			print("is_reverse ", is_reverse)
			card_node.get_node("TypeCardLabel").text = "Descripción"
			card_node.get_node("DescriptionCardLabel").text = card.descripcion
			
	elif GameConfig.game_mode == "Estrategia":
		if is_reverse:
			card_node.get_node("EmpathyTextureRect").visible = false
			card_node.get_node("EmotionalSupportTextureRect").visible = false
			card_node.get_node("InterventionTextureRect").visible = false
			print("is_reverse ", is_reverse)
			card_node.get_node("TypeCardLabel").text = "Descripción"
			card_node.get_node("DescriptionCardLabel").text = card.descripcion
		else:
			card_node.get_node("EmpathyTextureRect").visible = true
			card_node.get_node("EmotionalSupportTextureRect").visible = true
			card_node.get_node("InterventionTextureRect").visible = true
			# Mostrar estadísticas de la carta
			card_node.get_node("TypeCardLabel").text = "Estadísticas"
			card_node.get_node("DescriptionCardLabel").text = ""

			# Configurar las estadísticas (Empatía, Apoyo, etc.)

			var icon_path = ""
			var texture_icon

			# Empatía
			icon_path = "res://assets/ui/icons/empathy_gradient_blue_red_20_" + str(clamp(card.empatia, 1, 10)) + ".png"
			texture_icon = load(icon_path)
			if texture_icon:
				card_node.get_node("EmpathyTextureRect").texture = texture_icon
				card_node.get_node("EmpathyTextureRect").tooltip_text = "Empatía: " + str(card.empatia)
			else:
				print("Error: No se pudo cargar la imagen para la estadística Empatía")

			# Apoyo emocional
			icon_path = "res://assets/ui/icons/apoyo_emocional_gradient_blue_red_20_" + str(clamp(card.apoyo_emocional, 1, 10)) + ".png"
			texture_icon = load(icon_path)
			if texture_icon:
				card_node.get_node("EmotionalSupportTextureRect").texture = texture_icon
				card_node.get_node("EmotionalSupportTextureRect").tooltip_text = "Apoyo Emocional: " + str(card.apoyo_emocional)
			else:
				print("Error: No se pudo cargar la imagen para la estadística Apoyo Emocional")

			# Intervención
			icon_path = "res://assets/ui/icons/intervención_gradient_blue_red_20_" + str(clamp(card.intervencion, 1, 10)) + ".png"
			texture_icon = load(icon_path)
			if texture_icon:
				card_node.get_node("InterventionTextureRect").texture = texture_icon
				card_node.get_node("InterventionTextureRect").tooltip_text = "Intervención: " + str(card.intervencion)
			else:
				print("Error: No se pudo cargar la imagen para la estadística Intervención")

			

   
	# Mapeo de nombres de afinidades a nombres de archivos de imagen
	var affinity_image_map = {
		"Sexual": "token_sexual.png",
		"Verbal": "token_verbal.png",
		"Físico": "token_físico.png",
		"Ciberbullying": "token_ciberbullying.png",
		"Psicológico": "token_psicologico.png",
		"Exclusión Social": "token_exclusión_social.png"
	}
	# Lista de afinidades altas y los nodos Token
	var high_affinity_keys = []  # Lista para guardar los aspectos con alta afinidad
	for key in card.afinidad.keys():
		if card.afinidad[key] == "Alta":
			print("AFINIDAD                                : " + key + " " + card.afinidad[key])
			high_affinity_keys.append(key)


	# Nodos Token
	var tokens = [
		card_image_node.get_node("Token1"),
		card_image_node.get_node("Token2"),
		card_image_node.get_node("Token3"),
		card_image_node.get_node("Token4")
	]

	# Si no hay afinidades altas, ocultar todos los tokens
	if high_affinity_keys.size() == 0:
		for token in tokens:
			if token != null:  # Validar que el token no sea null
				token.visible = false
		return

	# Mostrar los tokens correspondientes a las afinidades altas
	for i in range(4):  # Hasta 4 tokens máximo
		if i < high_affinity_keys.size():
			tokens[i].visible = true
			# Cambiar el tooltip del token para reflejar la afinidad
			tokens[i].tooltip_text = "Afinidad: " + high_affinity_keys[i]

			# Obtener el nombre de la imagen correspondiente a la afinidad
			var affinity_key = high_affinity_keys[i]
			if affinity_key in affinity_image_map:
				var affinity_image_path = "res://assets/ui/tokens/" + affinity_image_map[affinity_key]
				var affinity_texture = load(affinity_image_path)
				if affinity_texture:
					tokens[i].texture = affinity_texture
				else:
					print("Error: No se pudo cargar la imagen de afinidad en la ruta: ", affinity_image_path)
		elif tokens[i] != null:
			tokens[i].visible = false
			tokens[i].tooltip_text = ""  # Limpiar el tooltip

		
# Función para actualizar la interfaz con los datos de la carta de tipo RE de la IA
func display_ia_card_re(card: CardsRE, card_node: Control, is_reverse: bool):
	# Obtener la referencia al nodo de la imagen de la carta
	var card_image_node = card_node.get_node("CardImage")
	# Construir la ruta a la imagen basándonos en el id de la carta
	var image_path = "res://assets/images/cards/re/" + str(card.id_carta) + "_RE.webp"
	# Cargar la imagen
	var texture = load(image_path)
	# Verificar si la textura fue cargada correctamente
	if texture:
		# Establecer la textura en el nodo `CardImage`
		card_image_node.texture = texture
	else:
		# Mostrar un mensaje de error si la imagen no se encuentra
		print("Error: No se pudo cargar la imagen en la ruta: ", image_path)

	
	# Actualiza los elementos de la UI en el nodo de la carta especificada y muestra si es reverso o anverso
	card_node.get_node("TitleCardLabel").text = card.nombre
	card_node.get_node("NumberCardLabel").text = str(card.id_carta)
	if is_reverse:
		print("is_reverse ", is_reverse)
		card_node.get_node("TypeCardLabel").text = "Contexto en el juego"
		card_node.get_node("DescriptionCardLabel").text = card.contexto_en_el_juego
	else:
		print("is_reverse ", is_reverse)
		card_node.get_node("TypeCardLabel").text = "Descripción"
		card_node.get_node("DescriptionCardLabel").text = card.descripcion

# Función para actualizar la interfaz con los datos de la carta de tipo HS de la IA
func display_ia_card_hs(card: CardsHS, card_node: Control, is_reverse: bool):
	# Obtener la referencia al nodo de la imagen de la carta
	var card_image_node = card_node.get_node("CardImage")
	# Construir la ruta a la imagen basándonos en el id de la carta
	var image_path = "res://assets/images/cards/hs/" + str(card.id_carta) + "_HS.webp"
	# Cargar la imagen
	var texture = load(image_path)
	# Verificar si la textura fue cargada correctamente
	if texture:
		# Establecer la textura en el nodo `CardImage`
		card_image_node.texture = texture
	else:
		# Mostrar un mensaje de error si la imagen no se encuentra
		print("Error: No se pudo cargar la imagen en la ruta: ", image_path)

	# Actualiza los elementos de la UI en el nodo de la carta especificada y muestra si es reverso o anverso
	card_node.get_node("TitleCardLabel").text = card.nombre
	card_node.get_node("NumberCardLabel").text = str(card.id_carta)
	if is_reverse:
		print("is_reverse ", is_reverse)
		card_node.get_node("TypeCardLabel").text = "Contexto en el juego"
		card_node.get_node("DescriptionCardLabel").text = card.contexto_en_el_juego
	else:
		print("is_reverse ", is_reverse)
		card_node.get_node("TypeCardLabel").text = "Descripción"
		card_node.get_node("DescriptionCardLabel").text = card.descripcion


# Función para actualizar la interfaz con los datos de la carta de tipo HS
func display_card_hs(card: CardsHS, card_node: Control, is_reverse: bool):
	# Obtener la referencia al nodo de la imagen de la carta
	var card_image_node = card_node.get_node("CardImage")
	# Construir la ruta a la imagen basándonos en el id de la carta
	var image_path = "res://assets/images/cards/hs/" + str(card.id_carta) + "_HS.webp"
	# Cargar la imagen
	var texture = load(image_path)
	# Verificar si la textura fue cargada correctamente
	if texture:
		# Establecer la textura en el nodo `CardImage`
		card_image_node.texture = texture
	else:
		# Mostrar un mensaje de error si la imagen no se encuentra
		print("Error: No se pudo cargar la imagen en la ruta: ", image_path)

	# Actualiza los elementos de la UI en el nodo de la carta especificada	
	card_node.get_node("TitleCardLabel").text = card.nombre
	card_node.get_node("NumberCardLabel").text = str(card.id_carta)
	#card_node.get_node("TypeCardLabel").text = "Empatía: %d, Apoyo: %d, Intervención: %d" % [card.empatia, card.apoyo_emocional, card.intervencion]
	#card_node.get_node("DescriptionCardLabel").text = card.descripcion
	if GameConfig.game_mode == "Intuición":
		if is_reverse:
			print("is_reverse ", is_reverse)
			card_node.get_node("TypeCardLabel").text = "Contexto en el juego"
			card_node.get_node("DescriptionCardLabel").text = card.contexto_en_el_juego
		else:
			print("is_reverse ", is_reverse)
			card_node.get_node("TypeCardLabel").text = "Descripción"
			card_node.get_node("DescriptionCardLabel").text = card.descripcion
			
	elif GameConfig.game_mode == "Estrategia":
		if is_reverse:
			card_node.get_node("ComunicationTextureRect").visible = false
			card_node.get_node("ConflictResolutionTextureRect").visible = false
			print("is_reverse ", is_reverse)
			card_node.get_node("TypeCardLabel").text = "Descripción"
			card_node.get_node("DescriptionCardLabel").text = card.descripcion
		else:
			card_node.get_node("ComunicationTextureRect").visible = true
			card_node.get_node("ConflictResolutionTextureRect").visible = true
			# Mostrar estadísticas de la carta
			card_node.get_node("TypeCardLabel").text = "Estadísticas"
			card_node.get_node("DescriptionCardLabel").text = ""

			# Configurar las estadísticas (Empatía, Apoyo, etc.)

			var icon_path = ""
			var texture_icon

				## Empatía
				#icon_path = "res://assets/ui/icons/empathy_gradient_blue_red_20_" + str(clamp(card.empatia, 1, 10)) + ".png"
				#texture_icon = load(icon_path)
				#if texture_icon:
					#stats_node.get_node("EmpathyTextureRect").texture = texture_icon
					#stats_node.get_node("EmpathyTextureRect").tooltip_text = "Empatía: " + str(card.empatia)
				#else:
					#print("Error: No se pudo cargar la imagen para la estadística Empatía")
#
				## Apoyo emocional
				#icon_path = "res://assets/ui/icons/apoyo_emocional_gradient_blue_red_20_" + str(clamp(card.apoyo_emocional, 1, 10)) + ".png"
				#texture_icon = load(icon_path)
				#if texture_icon:
					#stats_node.get_node("EmotionalSupportTextureRect").texture = texture_icon
					#stats_node.get_node("EmotionalSupportTextureRect").tooltip_text = "Apoyo Emocional: " + str(card.apoyo_emocional)
				#else:
					#print("Error: No se pudo cargar la imagen para la estadística Apoyo Emocional")
#
				## Intervención
				#icon_path = "res://assets/ui/icons/intervención_gradient_blue_red_20_" + str(clamp(card.intervencion, 1, 10)) + ".png"
				#texture_icon = load(icon_path)
				#if texture_icon:
					#stats_node.get_node("InterventionTextureRect").texture = texture_icon
					#stats_node.get_node("InterventionTextureRect").tooltip_text = "Intervención: " + str(card.intervencion)
				#else:
					#print("Error: No se pudo cargar la imagen para la estadística Intervención")

				# Comunicación
			icon_path = "res://assets/ui/icons/comunicacion_gradient_blue_red_20_" + str(clamp(card.comunicacion, 1, 10)) + ".png"
			texture_icon = load(icon_path)
			if texture_icon:
				card_node.get_node("ComunicationTextureRect").texture = texture_icon
				card_node.get_node("ComunicationTextureRect").tooltip_text = "Comunicación: " + str(card.comunicacion)
			else:
				print("Error: No se pudo cargar la imagen para la estadística Comunicación")

			# Resolución de Conflictos
			icon_path = "res://assets/ui/icons/resolución_de_conflictos_gradient_blue_red_20_" + str(clamp(card.resolucion_de_conflictos, 1, 10)) + ".png"
			texture_icon = load(icon_path)
			if texture_icon:
				card_node.get_node("ConflictResolutionTextureRect").texture = texture_icon
				card_node.get_node("ConflictResolutionTextureRect").tooltip_text = "Resolución de Conflictos: " + str(card.resolucion_de_conflictos)
			else:
				print("Error: No se pudo cargar la imagen para la estadística Resolución de Conflictos")

	# Mapeo de nombres de afinidades a nombres de archivos de imagen
	var affinity_image_map = {
		"Sexual": "token_sexual.png",
		"Verbal": "token_verbal.png",
		"Físico": "token_físico.png",
		"Ciberbullying": "token_ciberbullying.png",
		"Psicológico": "token_psicologico.png",
		"Exclusión Social": "token_exclusión_social.png"
	}
	# Lista de afinidades altas y los nodos Token
	var high_affinity_keys = []  # Lista para guardar los aspectos con alta afinidad
	for key in card.afinidad.keys():
		if card.afinidad[key] == "Alta":
			print("AFINIDAD                                : " + key + " " + card.afinidad[key])
			high_affinity_keys.append(key)


	# Nodos Token
	var tokens = [
		card_image_node.get_node("Token1"),
		card_image_node.get_node("Token2"),
		card_image_node.get_node("Token3"),
		card_image_node.get_node("Token4")
	]

	# Si no hay afinidades altas, ocultar todos los tokens
	if high_affinity_keys.size() == 0:
		for token in tokens:
			if token != null:  # Validar que el token no sea null
				token.visible = false
		return

	# Mostrar los tokens correspondientes a las afinidades altas
	for i in range(4):  # Hasta 4 tokens máximo
		if i < high_affinity_keys.size():
			tokens[i].visible = true
			# Cambiar el tooltip del token para reflejar la afinidad
			tokens[i].tooltip_text = "Afinidad: " + high_affinity_keys[i]

			# Obtener el nombre de la imagen correspondiente a la afinidad
			var affinity_key = high_affinity_keys[i]
			if affinity_key in affinity_image_map:
				var affinity_image_path = "res://assets/ui/tokens/" + affinity_image_map[affinity_key]
				var affinity_texture = load(affinity_image_path)
				if affinity_texture:
					tokens[i].texture = affinity_texture
				else:
					print("Error: No se pudo cargar la imagen de afinidad en la ruta: ", affinity_image_path)
		elif tokens[i] != null:
			tokens[i].visible = false
			tokens[i].tooltip_text = ""  # Limpiar el tooltip


# Función para actualizar la interfaz con los datos de la carta de bullying
func display_card_bu(card: CardsBU, card_node: Control, is_reverse: bool):

	# Obtener la referencia al nodo de la imagen de la carta
	var card_image_node = card_node.get_node("CardImage")
	# Construir la ruta a la imagen basándonos en el id de la carta
	var image_path = "res://assets/images/cards/bu/" + str(card.id_carta) + "_BU.webp"
	# Cargar la imagen
	var texture = load(image_path)
	var icon_path = ""  # Crear la ruta completa del icono
	var texture_icon
	# Verificar si la textura fue cargada correctamente
	if texture:
		# Establecer la textura en el nodo `CardImage`
		card_image_node.texture = texture
	else:
		# Mostrar un mensaje de error si la imagen no se encuentra
		print("Error: No se pudo cargar la imagen en la ruta: ", image_path)
	# Actualiza los elementos de la UI en el nodo de la carta especificada
	card_node.get_node("TitleCardLabel").text = card.nombre
	card_node.get_node("NumberCardLabel").text = str(card.id_carta) 
	card_node.get_node("TypeCardLabel").text = card.tipo
	# Verifica el modo de juego
	if GameConfig.game_mode == "Intuición":

		#card_node.get_node("TypeCardLabel").text = card.tipo
		if is_reverse:
			print("is_reverse ", is_reverse)
			print("updatebu_necesidadclave", card.necesidades_clave)
			
			card_node.get_node("DescriptionCardLabel").text = "Enfoque principal: \n" + card.enfoque_principal
			
		else:
			print("is_reverse ", is_reverse)
			card_node.get_node("DescriptionCardLabel").text = card.descripcion
			
	elif GameConfig.game_mode == "Estrategia":
		# Modo Estrategia:
				# Actualiza los elementos de la UI en el nodo de la carta especificada
		#card_node.get_node("TitleCardLabel").text = card.nombre
		#card_node.get_node("NumberCardLabel").text = str(card.id_carta) 
		#card_node.get_node("TypeCardLabel").text = card.tipo
		if is_reverse:
			stats_bu.visible = false
			print("is_reverse ", is_reverse)
			print("updatebu_necesidadclave", card.necesidades_clave)
			#card_node.get_node("TypeCardLabel").text = card.tipo
			card_node.get_node("DescriptionCardLabel").text = card.descripcion
			#card_node.get_node("DescriptionCardLabel").text = "Enfoque principal: \n" + card.enfoque_principal
			
		else:
			stats_bu.visible = true
			var stats_node = card_node.get_node("StatsBu")
			card_node.get_node("DescriptionCardLabel").text = ""
			icon_path = "res://assets/ui/icons/empathy_gradient_blue_red_20_" + str(clamp(card.empatia, 1, 10)) + ".png"  # Crear la ruta completa del icono
			texture_icon = load(icon_path)
			if texture_icon:
				empathy_texture_rect.texture = texture_icon
				empathy_texture_rect.tooltip_text = "Empatía: " + str(card.empatia)
			else:
				print("Error: No se pudo cargar la imagen para la estadística Empatía")	
						
			icon_path = "res://assets/ui/icons/apoyo_emocional_gradient_blue_red_20_" + str(clamp(card.apoyo_emocional, 1, 10)) + ".png"  # Crear la ruta completa del icono
			texture_icon = load(icon_path)
			if texture_icon:
				emotional_support_texture_rect.texture = texture_icon
				emotional_support_texture_rect.tooltip_text = "Apoyo Emocional: " + str(card.apoyo_emocional)
			else:
				print("Error: No se pudo cargar la imagen para la estadística Apoyo Emocional")			

			icon_path = "res://assets/ui/icons/intervención_gradient_blue_red_20_" + str(clamp(card.intervencion, 1, 10)) + ".png"  # Crear la ruta completa del icono
			texture_icon = load(icon_path)
			if texture_icon:
				intervention_texture_rect.texture = texture_icon
				intervention_texture_rect.tooltip_text = "Intervención: " + str(card.intervencion)
			else:
				print("Error: No se pudo cargar la imagen para la estadística Intervencion")			

			icon_path = "res://assets/ui/icons/comunicacion_gradient_blue_red_20_" + str(clamp(card.comunicacion, 1, 10)) + ".png"  # Crear la ruta completa del icono
			texture_icon = load(icon_path)
			if texture_icon:
				comunication_texture_rect.texture = texture_icon
				comunication_texture_rect.tooltip_text = "Comunicación: " + str(card.comunicacion)
			else:
				print("Error: No se pudo cargar la imagen para la estadística Comunicacion")			

			icon_path = "res://assets/ui/icons/resolución_de_conflictos_gradient_blue_red_20_" + str(clamp(card.resolucion_de_conflictos, 1, 10)) + ".png"  # Crear la ruta completa del icono
			texture_icon = load(icon_path)
			if texture_icon:
				conflict_resolution_texture_rect.texture = texture_icon
				conflict_resolution_texture_rect.tooltip_text = "Resolución de Conflictos: " + str(card.resolucion_de_conflictos)
			else:
				print("Error: No se pudo cargar la imagen para la estadística Resolucion de Conflictos")			



	# Cambiar el marco de la carta según su tipo
	var card_frame_node = card_node.get_node("CardFrame")  # Nodo `CardFrame` que cambia dependiendo del tipo
	var frame_path = "res://assets/images/frames/"
	
	# Definir el marco según el tipo de carta
	match card.tipo.to_lower():
		"verbal":
			frame_path = "res://assets/images/frames/black frame stat right.png"
		"físico":
			frame_path = "res://assets/images/frames/blue frame stat right.png"
		"ciberbullying":
			frame_path = "res://assets/images/frames/gray frame stat right.png"
		"exclusión social":
			frame_path = "res://assets/images/frames/green frame stat right.png"
		"psicológico":
			frame_path = "res://assets/images/frames/purple frame stat right.png"
		"sexual":
			frame_path = "res://assets/images/frames/yellow frame stat right.png"
	# Cargar la textura del marco
	var frame_texture = load(frame_path)
	if frame_texture:
		# Establecer la textura en el nodo `CardFrame`
		card_frame_node.texture = frame_texture
	else:
		print("Error: No se pudo cargar la textura del marco en la ruta: ", frame_path)
		

###############################################################################
###############################################################################
#                                UTILIDADES                                   #
###############################################################################
###############################################################################

# Función para deshabilitar la interacción con las cartas del jugador
func disable_card_interaction():
	# Iterar sobre cada carta y deshabilitar la interacción del ratón
	var cards = [re_card_1, re_card_2, re_card_3, hs_card_1, hs_card_2, hs_card_3]
	for card in cards:
		card.mouse_filter = Control.MOUSE_FILTER_IGNORE

# Función para habilitar la interacción con las cartas del jugador		
func enable_card_interaction():
	# Iterar sobre cada carta y habilitar la interacción del ratón
	var cards = [re_card_1, re_card_2, re_card_3, hs_card_1, hs_card_2, hs_card_3]
	for card in cards:
		card.mouse_filter = Control.MOUSE_FILTER_PASS

# Función de consulta del estado del juego
func get_current_state() -> GameState:
	return current_state

# Función para saber si el jugador ha elegido cartas
func has_player_chosen() -> bool:
	return player_chosen

# Función para saber si la IA ha elegido cartas
func has_ia_chosen() -> bool:
	return ia_chosen

# Maneja la señal y actualiza la visualización de las cartas
func _on_reverse_anverse_toggled(showing_reverses: bool):
	play_beep_sound("res://assets/audio/sfx/flipcard-91468.mp3")
	# Actualizar las cartas RE
	display_card_re(player_cards_re[0], re_card_1, showing_reverses)
	display_card_re(player_cards_re[1], re_card_2, showing_reverses)
	display_card_re(player_cards_re[2], re_card_3, showing_reverses)
	
	# Actualizar las cartas HS
	display_card_hs(player_cards_hs[0], hs_card_1, showing_reverses)
	display_card_hs(player_cards_hs[1], hs_card_2, showing_reverses)
	display_card_hs(player_cards_hs[2], hs_card_3, showing_reverses)
	#Actualiza la carta de bullyin
	display_card_bu(card_bullying, bullying_card, showing_reverses)


func _on_options_button_pressed():
	play_beep_sound("res://assets/audio/sfx/click.ogg")
	#game_over_control.visible = true
	#defeat_texture_rect.visible = true
	blur_overlay.visible = true
	new_game_option_window.visible = true

# Función para cargar el JSON de estrategias correctas
func load_strategy(file_path: String) -> Variant:
	var json_correct_strategy = null
	var file = FileAccess.open(file_path, FileAccess.READ)
	
	if file:
		var data = file.get_as_text()
		if data != "":
			# Crear una instancia de JSON
			var json = JSON.new()
			var parse_result = json.parse(data)
			if parse_result == OK:
				json_correct_strategy = json.data  # Accedemos al resultado del parseo
			else:
				print("Error al parsear JSON:", parse_result)  # Mostramos el código de error
		else:
			print("Archivo JSON vacío o sin datos.")
		file.close()
	else:
		print("Error: No se pudo abrir el archivo JSON:", file_path)
	
	return json_correct_strategy  # Siempre retorna, aunque sea null

# Función para buscar combinaciones en el JSON
func find_combination(json_data: Array, card_id: int, selected_re: int, selected_hs: int) -> Dictionary:
	# Buscar la carta por su idCarta
	for carta in json_data:
		if carta["idCarta"] == card_id:  # Acceso a idCarta usando corchetes
			print("Carta encontrada: ", carta["nombre"])
			# Buscar combinaciones que coincidan con RE y HS
			for combinacion in carta["Combinaciones"]:  # Acceso a Combinaciones con corchetes
				if combinacion["RE"] == selected_re and combinacion["HS"] == selected_hs:  # Acceso a RE y HS con corchetes
					print("Combinación encontrada:")
					print("  RE: ", combinacion["RE"], ", HS: ", combinacion["HS"])
					return combinacion  # Retornar la combinación coincidente
			break  # Terminar la búsqueda si se encontró la carta
	return {} # Retornar un Dictionary vacío si no se encontró ninguna combinación


func _on_continue_options_button_pressed():
	play_beep_sound("res://assets/audio/sfx/click.ogg")
	blur_overlay.visible = false
	new_game_option_window.visible = false


func _on_abort_button_pressed():
	play_beep_sound("res://assets/audio/sfx/click.ogg")
	GlobalData.game_over_abort = true
	change_state(GameState.GAME_OVER)

	# Función para reproducir el sonido
func play_beep_sound(audio_file: String):
	print("sonido: ", audio_file)
	# Cargar el archivo de audio en tiempo de ejecución
	var audio_stream = load(audio_file)
	# Asignar el audio al AudioStreamPlayer
	beep_audio_stream_player.stream = audio_stream
	#
	#if beep_audio_stream_player.playing:
		#beep_audio_stream_player.stop()
	beep_audio_stream_player.play()


# Diccionario para rastrear la cantidad de tokens previamente obtenidos
var last_token_count: Dictionary = {
	"ciberbullying": 0,
	"exclusión_social": 0,
	"físico": 0,
	"psicológico": 0,
	"sexual": 0,
	"verbal": 0
}
# Diccionario para rastrear la cantidad de tokens previamente obtenidos
var last_token_count_ia: Dictionary = {
	"ciberbullying": 0,
	"exclusión_social": 0,
	"físico": 0,
	"psicológico": 0,
	"sexual": 0,
	"verbal": 0
}
# Función para actualizar las texturas de los tokens
func update_token_textures():
	print("combo2: GlobalData.token_combos_player", GlobalData.token_combos_player)
	print("combo2: GlobalData.token_earned_player", GlobalData.token_earned_player)
	print("combo2: GlobalData.token_combos_ia", GlobalData.token_combos_ia)
	print("combo2: GlobalData.token_earned_ia", GlobalData.token_earned_ia)

	#
	## Actualizar el ComboHealth para cada tipo de bullying
	var combos_per_token = token_rules["verbal"]["combos_per_token"]
	var combos = GlobalData.token_combos_player["verbal"]		
	var progress = int(ceil(float(combos % combos_per_token) / combos_per_token * 10))
	print("combo: progress", progress)
	progress = clamp(progress, 1, 10)
	verbal_combo_health.texture = combo_health_textures[progress]
	## Actualizar el ComboHealth para cada tipo de bullying
	combos_per_token = token_rules["físico"]["combos_per_token"]
	combos = GlobalData.token_combos_player["físico"]		
	progress = int(ceil(float(combos % combos_per_token) / combos_per_token * 10))
	print("combo: progress", progress)
	progress = clamp(progress, 1, 10)
	fisic_combo_health.texture = combo_health_textures[progress]
	## Actualizar el ComboHealth para cada tipo de bullying
	combos_per_token = token_rules["sexual"]["combos_per_token"]
	combos = GlobalData.token_combos_player["sexual"]		
	progress = int(ceil(float(combos % combos_per_token) / combos_per_token * 10))
	print("combo: progress", progress)
	progress = clamp(progress, 1, 10)
	sexual_combo_health.texture = combo_health_textures[progress]
	## Actualizar el ComboHealth para cada tipo de bullying
	combos_per_token = token_rules["psicológico"]["combos_per_token"]
	combos = GlobalData.token_combos_player["psicológico"]		
	progress = int(ceil(float(combos % combos_per_token) / combos_per_token * 10))
	print("combo: progress", progress)
	progress = clamp(progress, 1, 10)
	psicologic_combo_health.texture = combo_health_textures[progress]
	## Actualizar el ComboHealth para cada tipo de bullying
	combos_per_token = token_rules["exclusión_social"]["combos_per_token"]
	combos = GlobalData.token_combos_player["exclusión_social"]		
	progress = int(ceil(float(combos % combos_per_token) / combos_per_token * 10))
	print("combo: progress", progress)
	progress = clamp(progress, 1, 10)
	exclusion_combo_health.texture = combo_health_textures[progress]
	## Actualizar el ComboHealth para cada tipo de bullying
	combos_per_token = token_rules["ciberbullying"]["combos_per_token"]
	combos = GlobalData.token_combos_player["ciberbullying"]		
	progress = int(ceil(float(combos % combos_per_token) / combos_per_token * 10))
	print("combo: progress", progress)
	progress = clamp(progress, 1, 10)
	ciber_combo_health.texture = combo_health_textures[progress]				
	
	#
	## Actualizar el ComboHealth para cada tipo de bullying
	combos_per_token = token_rules["verbal"]["combos_per_token"]
	combos = GlobalData.token_combos_ia["verbal"]		
	progress = int(ceil(float(combos % combos_per_token) / combos_per_token * 10))
	print("combo: progress", progress)
	progress = clamp(progress, 1, 10)
	verbal_combo_health_ia.texture = combo_health_textures[progress]
	## Actualizar el ComboHealth para cada tipo de bullying
	combos_per_token = token_rules["físico"]["combos_per_token"]
	combos = GlobalData.token_combos_ia["físico"]		
	progress = int(ceil(float(combos % combos_per_token) / combos_per_token * 10))
	print("combo: progress", progress)
	progress = clamp(progress, 1, 10)
	fisic_combo_health_ia.texture = combo_health_textures[progress]
	## Actualizar el ComboHealth para cada tipo de bullying
	combos_per_token = token_rules["sexual"]["combos_per_token"]
	combos = GlobalData.token_combos_ia["sexual"]		
	progress = int(ceil(float(combos % combos_per_token) / combos_per_token * 10))
	print("combo: progress", progress)
	progress = clamp(progress, 1, 10)
	sexual_combo_health_ia.texture = combo_health_textures[progress]
	## Actualizar el ComboHealth para cada tipo de bullying
	combos_per_token = token_rules["psicológico"]["combos_per_token"]
	combos = GlobalData.token_combos_ia["psicológico"]		
	progress = int(ceil(float(combos % combos_per_token) / combos_per_token * 10))
	print("combo: progress", progress)
	progress = clamp(progress, 1, 10)
	psicologic_combo_health_ia.texture = combo_health_textures[progress]
	## Actualizar el ComboHealth para cada tipo de bullying
	combos_per_token = token_rules["exclusión_social"]["combos_per_token"]
	combos = GlobalData.token_combos_ia["exclusión_social"]		
	progress = int(ceil(float(combos % combos_per_token) / combos_per_token * 10))
	print("combo: progress", progress)
	progress = clamp(progress, 1, 10)
	exclusion_combo_health_ia.texture = combo_health_textures[progress]
	## Actualizar el ComboHealth para cada tipo de bullying
	combos_per_token = token_rules["ciberbullying"]["combos_per_token"]
	combos = GlobalData.token_combos_ia["ciberbullying"]		
	progress = int(ceil(float(combos % combos_per_token) / combos_per_token * 10))
	print("combo: progress", progress)
	progress = clamp(progress, 1, 10)
	ciber_combo_health_ia.texture = combo_health_textures[progress]				
	
	
		
	 # Mapear los nodos a sus respectivos tipos
	token_nodes = {
		"exclusión_social": exclusion_social_token,
		"físico": fisico_token,
		"psicológico": psicologico_token,
		"sexual": sexual_token,
		"verbal": verbal_token,
		"ciberbullying": ciberbullying_token
	}
		 # Mapear los nodos a sus respectivos tipos
	token_nodes_ia = {
		"exclusión_social": exclusion_social_token_ia,
		"físico": fisico_token_ia,
		"psicológico": psicologico_token_ia,
		"sexual": sexual_token_ia,
		"verbal": verbal_token_ia,
		"ciberbullying": ciberbullying_token_ia
	}
	# Iterar sobre los tipos de bullying player
	for bullying_type in GlobalData.token_earned_player.keys():
		if GlobalData.token_earned_player[bullying_type] > 0:  # Si se ha ganado al menos un token
			if token_nodes.has(normalize_bullying_type(bullying_type)) and token_textures.has(normalize_bullying_type(bullying_type)):
				var token_node = token_nodes[bullying_type]
				var new_texture = token_textures[bullying_type]
				
				if token_node and new_texture:
					token_node.texture = new_texture  # Cambiar la textura
				# Actualizar el Label del token para mostrar el número de tokens ganados
				var token_label = token_node.get_node("Panel/Label")  
				if token_label:
					token_label.text = str(GlobalData.token_earned_player[bullying_type])  # Actualizar con el número de tokens

				# Verificar si el número de tokens ha aumentado
				var current_count = GlobalData.token_earned_player[bullying_type]
				if current_count > last_token_count[bullying_type]:  # Si hay un nuevo token
					play_token_audio(normalize_bullying_type(bullying_type))
					last_token_count[bullying_type] = current_count  # Actualizar el conteo
	# Iterar sobre los tipos de bullying ia
	for bullying_type in GlobalData.token_earned_ia.keys():
		if GlobalData.token_earned_ia[bullying_type] > 0:  # Si se ha ganado al menos un token
			if token_nodes_ia.has(normalize_bullying_type(bullying_type)) and token_textures.has(normalize_bullying_type(bullying_type)):
				var token_node = token_nodes_ia[bullying_type]
				var new_texture = token_textures[bullying_type]
				
				if token_node and new_texture:
					token_node.texture = new_texture  # Cambiar la textura
				# Actualizar el Label del token para mostrar el número de tokens ganados
				var token_label = token_node.get_node("Panel/Label")  
				if token_label:
					token_label.text = str(GlobalData.token_earned_ia[bullying_type])  # Actualizar con el número de tokens

				# Verificar si el número de tokens ha aumentado
				var current_count_ia = GlobalData.token_earned_ia[bullying_type]
				if current_count_ia > last_token_count_ia[bullying_type]:  # Si hay un nuevo token
					#play_token_audio(normalize_bullying_type(bullying_type))
					last_token_count_ia[bullying_type] = current_count_ia  # Actualizar el conteo

		
# Diccionario con los archivos de audio para cada token
var token_sfx: Dictionary = {
	"ciberbullying": [
		"res://assets/audio/sfx/ciberbullying_1.ogg",
		"res://assets/audio/sfx/ciberbullying_2.ogg"
	],
	"exclusión_social": [
		"res://assets/audio/sfx/exclusión_social.ogg",
		"res://assets/audio/sfx/exclusión_social_2.ogg"
	],
	"físico": [
		"res://assets/audio/sfx/físico_1.ogg",
		"res://assets/audio/sfx/físico_2.ogg"
	],
	"psicológico": [
		"res://assets/audio/sfx/psicológico_1.ogg",
		"res://assets/audio/sfx/psicológico_2.ogg"
	],
	"sexual": [
		"res://assets/audio/sfx/sexual_1.ogg",
		"res://assets/audio/sfx/sexual_2.ogg"
	],
	"verbal": [
		"res://assets/audio/sfx/verbal_1.ogg",
		"res://assets/audio/sfx/verbal_2.ogg"
	]
}
# Diccionario que asocia cada archivo de sonido con su mensaje
var token_sfx_messages: Dictionary = {
	"res://assets/audio/sfx/sexual_1.ogg": "¡Increíble! Has conseguido un token de comprensión sobre el bullying sexual.",
	"res://assets/audio/sfx/sexual_2.ogg": "¡Otro paso adelante! Un token de tipo sexual es tuyo.",
	"res://assets/audio/sfx/verbal_1.ogg": "¡Gran trabajo! Has ganado un token por abordar el bullying verbal.",
	"res://assets/audio/sfx/verbal_2.ogg": "¡Bien hecho! Un token de bullying verbal se une a tu marcador.",
	"res://assets/audio/sfx/físico_1.ogg": "Has obtenido un token por superar el bullying físico. ¡Sigues avanzando!",
	"res://assets/audio/sfx/físico_2.ogg": "Un token de tipo físico ahora es tuyo.",
	"res://assets/audio/sfx/ciberbullying_1.ogg": "¡Fantástico! Has logrado un token por tratar el ciberbullying.",
	"res://assets/audio/sfx/ciberbullying_2.ogg": "¡Sigue así! Un token de ciberbullying ha sido desbloqueado.",
	"res://assets/audio/sfx/psicológico_1.ogg": "¡Bien hecho! Has conseguido un token por tratar el bullying psicológico.",
	"res://assets/audio/sfx/psicológico_2.ogg": "¡Gran progreso! Un token de tipo psicológico es tuyo.",
	"res://assets/audio/sfx/exclusión_social.ogg": "¡Felicidades! Un token de exclusión social se une a tu marcador.",
	"res://assets/audio/sfx/exclusión_social_2.ogg": "¡Increíble! Has desbloqueado un token por abordar la exclusión social."
}
func play_token_audio(token_type: String):
	print("suena audio")
	if token_sfx.has(token_type):
		var sfx_list = token_sfx[token_type]
		if sfx_list.size() > 0:
			var random_index = randi() % sfx_list.size()  # Selecciona aleatoriamente
			var selected_sfx_path = sfx_list[random_index]  # Ruta al archivo de sonido
			var selected_sfx = load(selected_sfx_path)

			# Reproducir el archivo de audio
			#var audio_player = $"../UI/AudioStreamToken"  # Asegúrate de tener un nodo AudioStreamPlayer en tu escena
			audio_stream_token.stream = selected_sfx
			var volume_db = lerp(-80, 0, GameConfig.sfx_volume / 100.0)
			audio_stream_token.volume_db = volume_db
			audio_stream_token.play()

			# Llamada a token_sfx_messages para obtener el mensaje asociado
			if token_sfx_messages.has(selected_sfx_path):
				var message = token_sfx_messages[selected_sfx_path]  # Mensaje correspondiente al audio
				display_message(message)  # Mostrar el mensaje	
				
func display_message(message: String):
	if subtitles_control and subtitles_label:
		subtitles_label.text = message  # Mostrar el mensaje en el Label
		subtitles_control.visible = true  # Hacer visible el control que contiene el subtítulo


func _on_audio_stream_token_finished():
	if subtitles_label:
		subtitles_control.visible = false


func update_token_textures_game_over():
	# Referencia a los nodos de los tokens del jugador
	var player_token_nodes = {
		"exclusión_social": score_token_player.get_node("ExclusionSocialToken"),
		"físico": score_token_player.get_node("FisicoToken"),
		"psicológico": score_token_player.get_node("PsicologicoToken"),
		"sexual": score_token_player.get_node("SexualToken"),
		"verbal": score_token_player.get_node("VerbalToken"),
		"ciberbullying": score_token_player.get_node("CiberbullyingToken")
	}

	# Referencia a los nodos de los tokens de la IA
	var ia_token_nodes = {
		"exclusión_social": score_token_ia.get_node("ExclusionSocialToken"),
		"físico": score_token_ia.get_node("FisicoToken"),
		"psicológico": score_token_ia.get_node("PsicologicoToken"),
		"sexual": score_token_ia.get_node("SexualToken"),
		"verbal": score_token_ia.get_node("VerbalToken"),
		"ciberbullying": score_token_ia.get_node("CiberbullyingToken")
	}

	# Actualizar las texturas para los tokens del jugador
	for bullying_type in GlobalData.token_earned_player.keys():
		if GlobalData.token_earned_player[bullying_type] > 0:
			if player_token_nodes.has(bullying_type):
				var token_node = player_token_nodes[bullying_type]
				if token_textures.has(bullying_type):
					token_node.texture = token_textures[bullying_type]
					token_node.get_node("Panel/Label").text = str(GlobalData.token_earned_player[bullying_type])

	# Actualizar las texturas para los tokens de la IA
	for bullying_type in GlobalData.token_earned_ia.keys():
		if GlobalData.token_earned_ia[bullying_type] > 0:
			if ia_token_nodes.has(bullying_type):
				var token_node = ia_token_nodes[bullying_type]
				if token_textures.has(bullying_type):
					token_node.texture = token_textures[bullying_type]
					token_node.get_node("Panel/Label").text = str(GlobalData.token_earned_ia[bullying_type])
