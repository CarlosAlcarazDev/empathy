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
#	_on_ready_texture_button_pressed(): Función para manejar el evento del botón "Listo"
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
@onready var chosen_cards_label = $"../UI/ChosenCardsLabel"
@onready var chosen_cards_label_2 = $"../UI/ChosenCardsLabel2"
@onready var chosen_cards_label_3 = $"../UI/ChosenCardsLabel3"
@onready var chosen_cards_label_4 = $"../UI/ChosenCardsLabel4"
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
const COUNTDOWN_30_SECONDS = 15  # En segundos
const COUNTDOWN_20_MINUTES = 20 * 60  # En segundos (20 minutos)

# Variables de tiempo
var countdown_30_seconds = COUNTDOWN_30_SECONDS # Temporizador de turno
var countdown_20_minutes = COUNTDOWN_20_MINUTES # Temporizador de partida global
# Flag para controlar el sonido de cuenta regresiva, aseguramos que suena una vez
var countdown_sound_playing = false  

# Referencias adicionales de la interfaz
@onready var countdown_30_seconds_label = $"../UI/Countdown30SecondsLabel"
@onready var beep_countdown_audio_stream_player = $"../UI/BeepCountdownAudioStreamPlayer"
@onready var countdown_20_minutes_label = $"../UI/Countdown20MinutesLabel"
@onready var end_turn_popup = $"../UI/EndTurnPopup"
@onready var continue_button = $"../UI/EndTurnPopup/ContinueButton"
@onready var label = $"../UI/EndTurnPopup/Label"
@onready var label_2 = $"../UI/EndTurnPopup/Label2"
@onready var label_3 = $"../UI/EndTurnPopup/Label3"
@onready var label_4 = $"../UI/EndTurnPopup/Label4"
@onready var label_5 = $"../UI/EndTurnPopup/Label5"
@onready var ui = $"../UI"
@onready var blur_overlay = $"../UI/Overlay/BlurOverlay"


# Flag para controlar si jugador/IA han elegido cartas
var player_chosen = false
var ia_chosen = false

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

		


###############################################################################
###############################################################################
#                    INICIALIZACIÓN Y CONFIGURACIÓN                           #
###############################################################################
###############################################################################

# Función que se ejecuta al inicializar el nodo game_manager
func _ready():
	# Configurar el volumen del sonido
	var volume_db = lerp(-80, 0, GameConfig.sfx_volume / 100.0)
	beep_countdown_audio_stream_player.volume_db = volume_db
	
	# Cambia el estado inicial a "PREPARE"
	change_state(GameState.PREPARE)
	
	# Temporizador para sincronización regular del estado del juego
	var sync_timer = Timer.new()
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
	if countdown_30_seconds > 0:
		countdown_30_seconds -= delta
		# Actualizar la UI dependiendo del tiempo restante. Mostrar "Listo" cuando queden más de 10 segundos
		if countdown_30_seconds > 10:
			countdown_30_seconds_label.text = "Listo"
		else:
			# Mostrar la cuenta atrás uando queden 10 segundos o menos
			countdown_30_seconds_label.text = "%d" % max(int(countdown_30_seconds), 0)
			# Empezar el sonido de cuenta regresiva cuando quedan 10 segundos
			if countdown_30_seconds <= 10 and not countdown_sound_playing:
				beep_countdown_audio_stream_player.play()  # Reproduce el sonido
				countdown_sound_playing = true
	else:
		emit_signal("countdown_finished")
		# Seleccionar cartas automáticamente si no se han seleccionado
		if player_selected_card_re == null or player_selected_card_hs == null:
			auto_select_player_cards()
		if ia_selected_card_re == null or ia_selected_card_hs == null:
			auto_select_ia_cards()
		# Mover al siguiente estado
		change_state(GameState.CHECK_RESULT)
	# Actualizar el contador global de 20 minutos
	if countdown_20_minutes > 0:
		countdown_20_minutes -= delta
		countdown_20_minutes_label.text = "%d:%02d" % [int(countdown_20_minutes) / 60, int(countdown_20_minutes) % 60]

# Función para manejar el temporizador de sincronización
func _on_sync_timer_timeout():
	# Imprimir estado actual del juego (Depuración)
	print("Estado actual del juego: ", current_state)


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
	print("Turno del jugador y la IA.")
	# Reiniciar los estados del turno
	reset_turn_state()
	# Actualizar la carta de bullying
	update_bullying_card() 
	# La IA selecciona automaticamente sus cartas 
	choose_ia_cards()
	
# Función para verificar el resultado del turno
func check_game_result():
	# Asignar cartas para mostrar en el modal las cartas seleccionadas por jugador e IA
	label.text = ("Carta seleccionada por el jugador RE: " + str(player_selected_card_re))
	label_2.text = ("Carta seleccionada por el jugador HS: " + str(player_selected_card_hs))
	label_3.text = ("Carta seleccionada por la IA RE: " + str(ia_selected_card_re))
	label_4.text = ("Carta seleccionada por la IA HS: " + str(ia_selected_card_hs))
	label_5.text = ("Carta Situación de Bullying: "+ str(card_bullying.id_carta))

	# Deshabilitar interacción en las cartas y mostrar el modal
	disable_card_interaction()
	blur_overlay.visible = true
	end_turn_popup.show()
	
# Función cuando el juego termine
func game_over():
	print("Juego Terminado.")


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
	
	# Marcar que la IA ha terminado de elegir sus cartas
	ia_chosen = true
	
	# Mostrar las cartas elegidas en la consola para verificar
	print("Carta RE seleccionada por la IA: ", ia_selected_card_re)
	print("Carta HS seleccionada por la IA: ", ia_selected_card_hs)
	
# Función para reiniciar el estado del turno
func reset_turn_state():
	# Habilitar el botón "Listo" y restablecer el contador de tiempo
	ready_texture_button.disabled = false
	ready_texture_button.visible = true
	countdown_30_seconds_label.text = "Listo" 
	countdown_30_seconds = COUNTDOWN_30_SECONDS
	countdown_sound_playing = false
	
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
		change_state(GameState.GAME_OVER) # Cambia el estado del juego a "GAME_OVER"


###############################################################################
###############################################################################
#                           INTERACCIÓN DEL JUGADOR                           #
###############################################################################
###############################################################################

# Función para manejar el evento del botón "Listo"
func _on_ready_texture_button_pressed():
	if (player_selected_card_re == null or player_selected_card_hs == null):
		# Si el jugador no seleccionó cartas, asignarlas automáticamente
		auto_select_player_cards()
	
	# Detener el sonido de cuenta regresiva si está reproduciéndose
	if countdown_sound_playing:
		beep_countdown_audio_stream_player.stop()
		countdown_sound_playing = false  # Restablece flag
	
	#Finalizar la cuenta regresiva y desactivar el botón "Listo"
	countdown_30_seconds = 0
	countdown_30_seconds_label.text = "OK"
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

# Señal que se activa al presionar botón "Continuar"
func _on_continue_button_pressed():
	print("Iniciando el siguiente turno.")
	#Ocultar el modal y permitir interacción nuevamente
	ready_texture_button.disabled = false
	ready_texture_button.release_focus()  
	blur_overlay.visible = false
	end_turn_popup.hide()
	enable_card_interaction()
	
	# Verifica si el juego debe terminar (tiempo finalizado o no hay más cartas en el mazo bu) o iniciar el siguiente turno
	if countdown_20_minutes <= 0 or deck_manager.deck_bu.size() == 0:
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


# Función para actualizar la interfaz con los datos de la carta de bullying
func display_card_bu(card: CardsBU, card_node: Control, is_reverse: bool):
	# Obtener la referencia al nodo de la imagen de la carta
	var card_image_node = card_node.get_node("CardImage")
	# Construir la ruta a la imagen basándonos en el id de la carta
	var image_path = "res://assets/images/cards/bu/" + str(card.id_carta) + "_BU.webp"
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
	#card_node.get_node("TypeCardLabel").text = card.tipo
	if is_reverse:
		print("is_reverse ", is_reverse)
		print("updatebu_necesidadclave", card.necesidades_clave)
		card_node.get_node("TypeCardLabel").text = card.tipo
		card_node.get_node("DescriptionCardLabel").text = "Necesidades: \n" + card.necesidades_clave
		
	else:
		print("is_reverse ", is_reverse)
		card_node.get_node("DescriptionCardLabel").text = card.descripcion
		card_node.get_node("TypeCardLabel").text = card.tipo
	#card_node.get_node("DescriptionCardLabel").text = card.descripcion
	## Construir el texto para mostrar los stats en DescriptionCardLabel
	#var description_text = "Descripción:\n" + card.descripcion + "\n\n"
	#description_text += "Estadísticas:\n"
	#description_text += "- Empatía: " + str(card.empatia) + "\n"
	#description_text += "- Apoyo Emocional: " + str(card.apoyo_emocional) + "\n"
	#description_text += "- Intervención: " + str(card.intervencion) + "\n"
	#description_text += "- Comunicación: " + str(card.comunicacion) + "\n"
	#description_text += "- Resolución de Conflictos: " + str(card.resolucion_de_conflictos) + "\n\n"
## Asignar el texto formateado al nodo DescriptionCardLabel
	#card_node.get_node("DescriptionCardLabel").text = description_text

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
