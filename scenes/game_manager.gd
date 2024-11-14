#gamemanager.gd
#nodo encargado de gestionar los turnos, las acciones tanto del jugador como de la ia

extends Control

# Estados del juego
enum GameState {
	PREPARE,
	TURN,
	CHECK_RESULT,
	PAUSED,
	GAME_OVER
}


#Estado actual del juego al iniciar la partida
var current_state = GameState.PREPARE
@onready var chosen_cards_label = $"../UI/ChosenCardsLabel"
@onready var chosen_cards_label_2 = $"../UI/ChosenCardsLabel2"
@onready var chosen_cards_label_3 = $"../UI/ChosenCardsLabel3"
@onready var chosen_cards_label_4 = $"../UI/ChosenCardsLabel4"


# Referencias
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





# Constantes para los tiempos
const COUNTDOWN_30_SECONDS = 12  # En segundos
const COUNTDOWN_20_MINUTES = 20 * 60  # En segundos (20 minutos)

# Variables de tiempo
var countdown_30_seconds = COUNTDOWN_30_SECONDS
var countdown_20_minutes = COUNTDOWN_20_MINUTES
# Bandera para controlar el sonido de cuenta regresiva
var countdown_sound_playing = false  # Se asegura de que el sonido solo se reproduzca una vez

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

# Bandera para los estados de elección del jugador y la IA
var player_chosen = false
var ia_chosen = false

# Almacenar las cartas elegidas por el jugador y la IA
var player_selected_card_re = null
var player_selected_card_hs = null
var ia_selected_card_re = null
var ia_selected_card_hs = null

var player_cards_re = []
var player_cards_hs = []
var ai_cards_re = []
var ai_cards_hs = []
var card_bullying 

#Señales de estado
signal state_changed(new_state)
signal player_chosen_card(card_id)
signal ia_chosen_card(card_id)
signal countdown_finished()
signal ready_to_check_result()
signal card_chosen_re(card_id)
signal card_chosen_hs(card_id)

func _ready():
	# Conectar el botón de continuar para que cierre la ventana y pase al siguiente turno
	#inicia el juego
	change_state(GameState.PREPARE)
	# Temporizador para sincronización regular del estado del juego
	var sync_timer = Timer.new()
	sync_timer.set_wait_time(1.0)  # Cada 1 segundo
	sync_timer.set_one_shot(false)
	sync_timer.connect("timeout", Callable(self, "_on_sync_timer_timeout"))
	add_child(sync_timer)
	sync_timer.start()
		# Conectar señal de cartas elegidas
	# Conectar señal de cartas elegidas
	re_card_1.connect("card_chosen_re", Callable(self, "_on_card_chosen_re"))
	re_card_2.connect("card_chosen_re", Callable(self, "_on_card_chosen_re"))
	re_card_3.connect("card_chosen_re", Callable(self, "_on_card_chosen_re"))
	hs_card_1.connect("card_chosen_hs", Callable(self, "_on_card_chosen_hs"))
	hs_card_2.connect("card_chosen_hs", Callable(self, "_on_card_chosen_hs"))
	hs_card_3.connect("card_chosen_hs", Callable(self, "_on_card_chosen_hs"))
	
	
	
func _process(delta):
	# Manejar el estado de PLAYER_TURN y IA_TURN simultáneamente
	if current_state == GameState.TURN:
		handle_countdown(delta)
		
		# Si ambos (jugador y IA) han elegido sus cartas, cambia al siguiente estado
		if player_chosen and ia_chosen:
			emit_signal("ready_to_check_result")
			change_state(GameState.CHECK_RESULT)

# Manejar la cuenta regresiva de 30 segundos
func handle_countdown(delta):
	if countdown_30_seconds > 0:
		countdown_30_seconds -= delta
		# Mostrar "Listo" cuando queden más de 10 segundos
		if countdown_30_seconds > 10:
			# Actualizar el label en la UI para mostrar "Listo"
			countdown_30_seconds_label.text = "Listo"
		else:
			# Mostrar la cuenta regresiva cuando queden 10 segundos o menos
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
		## Mover al siguiente estado
		change_state(GameState.CHECK_RESULT)
	# Actualizar el contador de 20 minutos
	if countdown_20_minutes > 0:
		countdown_20_minutes -= delta
		countdown_20_minutes_label.text = "%d:%02d" % [int(countdown_20_minutes) / 60, int(countdown_20_minutes) % 60]
#
## Función para seleccionar cartas automáticamente para el jugador
func auto_select_player_cards():
	print("No se seleccionó carta para el jugador, asignando -1.")
	if player_selected_card_re == null:
		player_selected_card_re = -1  # Marca especial para indicar que no se seleccionó carta
	if player_selected_card_hs == null:
		player_selected_card_hs = -1

# Función para seleccionar cartas automáticamente para la IA
func auto_select_ia_cards():
	print("No se seleccionó carta para la IA, asignando -1.")
	if ia_selected_card_re == null:
		ia_selected_card_re = -1
	if ia_selected_card_hs == null:
		ia_selected_card_hs = -1
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

# Métodos de consulta del estado del juego
func get_current_state() -> GameState:
	return current_state

func has_player_chosen() -> bool:
	return player_chosen

func has_ia_chosen() -> bool:
	return ia_chosen

# Función para preparar el juego
func prepare_game():
	print("Preparando el juego...")
	# Repartir las cartas iniciales al jugador y a la IA
	deck_manager.load_cards_bu_from_json()
	deck_manager.load_cards_hs_from_json()
	deck_manager.load_cards_re_from_json()
	deck_manager.shuffle_deck_bu()
	deck_manager.shuffle_deck_re()
	deck_manager.shuffle_deck_hs()

		# Inicializar las listas de cartas del jugador y la IA
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
	#card_bullying = deck_manager.deck_bu.pop_back()
	
	display_card_re(player_cards_re[0], re_card_1)
	display_card_re(player_cards_re[1], re_card_2)
	display_card_re(player_cards_re[2], re_card_3)
	display_card_hs(player_cards_hs[0], hs_card_1)
	display_card_hs(player_cards_hs[1], hs_card_2)
	display_card_hs(player_cards_hs[2], hs_card_3)

   # Llamar a update_bullying_card para mostrar la primera carta de bullying
	update_bullying_card()
	display_card_bu(card_bullying, bullying_card)
	
	
	# Almacena las cartas de la IA en listas para que pueda seleccionarlas en `choose_ia_cards`
	ai_cards_re = [
		deck_manager.deck_re.pop_back() as CardsRE,
		deck_manager.deck_re.pop_back() as CardsRE,
		deck_manager.deck_re.pop_back() as CardsRE
	]
	ai_cards_hs = [
		deck_manager.deck_hs.pop_back() as CardsHS,
		deck_manager.deck_hs.pop_back() as CardsHS,
		deck_manager.deck_hs.pop_back() as CardsHS
	]	# Verifica que las cartas estén en el formato correcto
	
	# Cambiar al estado de turno del jugador e IA simultáneamente
	change_state(GameState.TURN)

# Función para manejar el turno del jugador
func start_turn():
	print("Turno del jugador y la IA.")
	reset_turn_state()
	update_bullying_card() 
	choose_ia_cards()
	
# Función para elegir las cartas de la IA de forma aleatoria
func choose_ia_cards():
	# Verifica que los mazos de la IA contengan cartas antes de intentar seleccionar
	#if deck_ia.cards_re.size() > 0 and deck_ia.cards_hs.size() > 0:
	print("La IA está eligiendo sus cartas.")
		## Seleccionar una carta aleatoria del mazo de RE y del mazo de HS
		# Genera índices aleatorios para seleccionar una carta de cada tipo
	var random_index_re = randi() % ai_cards_re.size()
	var random_index_hs = randi() % ai_cards_hs.size()

	# Accede a las cartas seleccionadas
	ia_selected_card_re = ai_cards_re[random_index_re].id_carta
	ia_selected_card_hs = ai_cards_hs[random_index_hs].id_carta
	
		#
		## Marcar que la IA ha elegido sus cartas
	ia_chosen = true
	
	

	# Marcar que la IA ha elegido sus cartas
	ia_chosen = true
	
	# Mostrar las cartas elegidas en la consola para verificar
	print("Carta RE seleccionada por la IA: ", ia_selected_card_re)
	print("Carta HS seleccionada por la IA: ", ia_selected_card_hs)
	
# Función para reiniciar el estado del turno
func reset_turn_state():
	ready_texture_button.disabled = false
	ready_texture_button.visible = true
	countdown_30_seconds_label.text = "Listo"  # Restablecer el texto de la cuenta regresiva
	countdown_30_seconds = COUNTDOWN_30_SECONDS
	countdown_sound_playing = false
	player_chosen = false
	ia_chosen = false
	player_selected_card_hs = null
	player_selected_card_re = null
	ia_selected_card_re = null
	ia_selected_card_hs = null


# Función para verificar el resultado de la jugada
func check_game_result():
	
	# Mostrar el Popup para que el jugador continúe
	label.text = ("Carta seleccionada por el jugador RE: " + str(player_selected_card_re))
	label_2.text = ("Carta seleccionada por el jugador HS: " + str(player_selected_card_hs))
	label_3.text = ("Carta seleccionada por la IA RE: " + str(ia_selected_card_re))
	label_4.text = ("Carta seleccionada por la IA HS: " + str(ia_selected_card_hs))
	label_5.text = ("Carta Situación de Bullying: "+ str(card_bullying.id_carta))
	#print("Comprobando resultado.")
	## Verificar las condiciones de victoria/derrota o si el juego continúa
	## Cambiar el est del juego según el resultado
	#chosen_cards_label.text = ("Carta seleccionada por el jugador RE: " + str(player_selected_card_re))
	#chosen_cards_label_2.text = ("Carta seleccionada por el jugador HS: " + str(player_selected_card_hs))
	#chosen_cards_label_3.text = ("Carta seleccionada por la IA RE: " + str(ia_selected_card_re))
	#chosen_cards_label_4.text = ("Carta seleccionada por la IA HS" + str(ia_selected_card_hs))
#
	#print("Carta seleccionada por el jugador RE: ", chosen_cards_label.text)
	#print("Carta seleccionada por el jugador HS: ", chosen_cards_label_2.text)
	#
	# Lógica para calcular puntos y determinar el resultado aquí
	# Esto dependerá de tus reglas de juego, pero asume que el puntaje se calcula y se imprime
# 	Remover las cartas seleccionadas para la próxima ronda
	disable_card_interaction()
	end_turn_popup.show()
	
	
# Función que se activa cuando el botón "Continuar" es presionado
func _on_continue_button_pressed():
	print("Iniciando el siguiente turno.")
	  # Volver a habilitar el botón y liberar su foco para reiniciar su estado visual
	ready_texture_button.disabled = false
	ready_texture_button.release_focus()  # Restablecer el estado visual a "Normal"
	# Cerrar el Popup
	end_turn_popup.hide()
	enable_card_interaction()
	# Verifica si el juego debe terminar o iniciar el siguiente turno
	if countdown_20_minutes <= 0 or deck_manager.deck_bu.size() == 0:
		change_state(GameState.GAME_OVER)
	else:
		replenish_cards()
		reset_turn_state()
		change_state(GameState.TURN)
	
func replenish_cards():
	# Remover las cartas seleccionadas del turno anterior
	remove_selected_cards()
	print("playercardresize")
	print(player_cards_re.size())
		# Asegúrate de devolver todas las cartas a la posición original antes de reponer
	
	# Asegurarse de que el mazo de cartas RE tenga al menos 3 cartas
	if deck_manager.deck_re.size() < 3:
		print("Recargando y barajando el mazo de cartas RE.")
		deck_manager.load_cards_re_from_json()
		deck_manager.shuffle_deck_re()

	# Asegurarse de que el mazo de cartas HS tenga al menos 3 cartas
	if deck_manager.deck_hs.size() < 3:
		print("Recargando y barajando el mazo de cartas HS.")
		deck_manager.load_cards_hs_from_json()
		deck_manager.shuffle_deck_hs()
		
	# Reponer cartas para el jugador si tiene menos de 3 cartas en cada lista
	while player_cards_re.size() < 3 and deck_manager.deck_re.size() > 0:
		player_cards_re.append(deck_manager.deck_re.pop_back())
	while player_cards_hs.size() < 3 and deck_manager.deck_hs.size() > 0:
		player_cards_hs.append(deck_manager.deck_hs.pop_back())

	# Reponer cartas para la IA si tiene menos de 3 cartas en cada lista
	while ai_cards_re.size() < 3 and deck_manager.deck_re.size() > 0:
		ai_cards_re.append(deck_manager.deck_re.pop_back() as CardsRE)
	while ai_cards_hs.size() < 3 and deck_manager.deck_hs.size() > 0:
		ai_cards_hs.append(deck_manager.deck_hs.pop_back() as CardsHS)
	
	re_card_1.move_to_original_position()
	re_card_2.move_to_original_position()
	re_card_3.move_to_original_position()
	hs_card_1.move_to_original_position()
	hs_card_2.move_to_original_position()
	hs_card_3.move_to_original_position()
	display_card_re(player_cards_re[0], re_card_1)
	display_card_re(player_cards_re[1], re_card_2)
	display_card_re(player_cards_re[2], re_card_3)
	display_card_hs(player_cards_hs[0], hs_card_1)
	display_card_hs(player_cards_hs[1], hs_card_2)
	display_card_hs(player_cards_hs[2], hs_card_3)
	print("Cartas reabastecidas para el jugador y la IA.")
	print("Contenido de player_cards_re después de reabastecidas:", player_cards_re)
	print("Contenido de player_cards_hs después de reabastecidas:", player_cards_hs)
	
			
func remove_selected_cards():
	print("Contenido de player_cards_re antes de borrar:", player_cards_re)
	print("Contenido de player_cards_hs antes de borrar:", player_cards_hs)
	print("Carta seleccionada por el jugador RE:", player_selected_card_re)
	print("Carta seleccionada por el jugador HS:", player_selected_card_hs)

	# Convertir `player_selected_card_re` y `player_selected_card_hs` a `int` si son cadenas
	var selected_re_id = int(player_selected_card_re) if typeof(player_selected_card_re) == TYPE_STRING else player_selected_card_re
	var selected_hs_id = int(player_selected_card_hs) if typeof(player_selected_card_hs) == TYPE_STRING else player_selected_card_hs

	# Remover la carta seleccionada de RE del jugador buscando por ID
	if selected_re_id != null:
		for card in player_cards_re:
			if card.id_carta == selected_re_id:
				player_cards_re.erase(card)
				break

	# Remover la carta seleccionada de HS del jugador buscando por ID
	if selected_hs_id != null:
		for card in player_cards_hs:
			if card.id_carta == selected_hs_id:
				player_cards_hs.erase(card)
				break

	# Convertir `ia_selected_card_re` y `ia_selected_card_hs` a `int` si son cadenas
	var selected_ai_re_id = int(ia_selected_card_re) if typeof(ia_selected_card_re) == TYPE_STRING else ia_selected_card_re
	var selected_ai_hs_id = int(ia_selected_card_hs) if typeof(ia_selected_card_hs) == TYPE_STRING else ia_selected_card_hs

	# Remover la carta seleccionada de RE de la IA buscando por ID
	if selected_ai_re_id != null:
		for card in ai_cards_re:
			if card.id_carta == selected_ai_re_id:
				ai_cards_re.erase(card)
				break

	# Remover la carta seleccionada de HS de la IA buscando por ID
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
# Función cuando el juego termine
func game_over():
	print("Juego Terminado.")
	# Aquí puedes implementar cualquier lógica necesaria para finalizar el juego, mostrar puntajes, etc.



# Función para actualizar la interfaz con los datos de la carta
func display_card_re(card: CardsRE, card_node: Control):
	# Actualiza los elementos de la UI en el nodo de la carta especificado

	# Obtener la referencia a `CardImage` que es un TextureRect
	var card_image_node = card_node.get_node("CardImage")
	
	# Construir la ruta a la imagen basándonos en el id de la carta
	var image_path = "res://assets/images/cards/re/" + str(card.id_carta) + "_RE.webp"
	
	# Intentar cargar la imagen
	var texture = load(image_path)
	
	# Verificar si la textura fue cargada correctamente
	if texture:
		# Establecer la textura en el nodo `CardImage`
		card_image_node.texture = texture
	else:
		# Si la imagen no fue encontrada, imprimir un error o manejar un caso sin imagen
		print("Error: No se pudo cargar la imagen en la ruta: ", image_path)

	# Actualiza los elementos de la UI en el nodo de la carta especificado
	
	card_node.get_node("TitleCardLabel").text = card.nombre
	card_node.get_node("NumberCardLabel").text = str(card.id_carta)
	#card_node.get_node("TypeCardLabel").text = "Empatía: %d, Apoyo: %d, Intervención: %d" % [card.empatia, card.apoyo_emocional, card.intervencion]
	card_node.get_node("DescriptionCardLabel").text = card.descripcion

# Función para actualizar la interfaz con los datos de la carta
func display_card_hs(card: CardsHS, card_node: Control):
	# Actualiza los elementos de la UI en el nodo de la carta especificado

	# Obtener la referencia a `CardImage` que es un TextureRect
	var card_image_node = card_node.get_node("CardImage")
	
	# Construir la ruta a la imagen basándonos en el id de la carta
	var image_path = "res://assets/images/cards/hs/" + str(card.id_carta) + "_HS.webp"
	
	# Intentar cargar la imagen
	var texture = load(image_path)
	
	# Verificar si la textura fue cargada correctamente
	if texture:
		# Establecer la textura en el nodo `CardImage`
		card_image_node.texture = texture
	else:
		# Si la imagen no fue encontrada, imprimir un error o manejar un caso sin imagen
		print("Error: No se pudo cargar la imagen en la ruta: ", image_path)

	# Actualiza los elementos de la UI en el nodo de la carta especificado
	
	card_node.get_node("TitleCardLabel").text = card.nombre
	card_node.get_node("NumberCardLabel").text = str(card.id_carta)
	#card_node.get_node("TypeCardLabel").text = "Empatía: %d, Apoyo: %d, Intervención: %d" % [card.empatia, card.apoyo_emocional, card.intervencion]
	card_node.get_node("DescriptionCardLabel").text = card.descripcion

# Función para actualizar la interfaz con los datos de la carta
func display_card_bu(card: CardsBU, card_node: Control):
	# Actualiza los elementos de la UI en el nodo de la carta especificado

	# Obtener la referencia a `CardImage` que es un TextureRect
	var card_image_node = card_node.get_node("CardImage")
	
	# Construir la ruta a la imagen basándonos en el id de la carta
	var image_path = "res://assets/images/cards/bu/" + str(card.id_carta) + "_BU.webp"
	
	# Intentar cargar la imagen
	var texture = load(image_path)
	
	# Verificar si la textura fue cargada correctamente
	if texture:
		# Establecer la textura en el nodo `CardImage`
		card_image_node.texture = texture
	else:
		# Si la imagen no fue encontrada, imprimir un error o manejar un caso sin imagen
		print("Error: No se pudo cargar la imagen en la ruta: ", image_path)

	# Actualiza los elementos de la UI en el nodo de la carta especificado
	
	card_node.get_node("TitleCardLabel").text = card.nombre
	card_node.get_node("NumberCardLabel").text = str(card.id_carta)
	card_node.get_node("TypeCardLabel").text = card.tipo
	card_node.get_node("DescriptionCardLabel").text = card.descripcion
	# Cambiar el marco de la carta según el tipo de carta
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
# Intentar cargar la textura del marco
	var frame_texture = load(frame_path)
	if frame_texture:
		# Establecer la textura en el nodo `CardFrame`
		card_frame_node.texture = frame_texture
	else:
		print("Error: No se pudo cargar la textura del marco en la ruta: ", frame_path)
# Función para manejar el temporizador de sincronización

func _on_sync_timer_timeout():
	print("Estado actual del juego: ", current_state)
	# Aquí enviarías esta información a los clientes conectados

# Función para manejar la selección de una carta
func _on_card_chosen_re(card_id):
	#var number_card_label2 = card_id
	player_selected_card_re = card_id
	#chosen_cards_label.text = number_card_label2
	
# Función para manejar la selección de una carta
func _on_card_chosen_hs(card_id):
	#var number_card_label2 = card_id
	player_selected_card_hs = card_id
	#chosen_cards_label_2.text = number_card_label2
	

# Función para manejar la señal del botón "Listo"
# Función para manejar la señal del botón "Listo"
func _on_ready_texture_button_pressed():
	if (player_selected_card_re == null or player_selected_card_hs == null):
		auto_select_player_cards()
		   # Detener el sonido de cuenta regresiva si está reproduciéndose
	if countdown_sound_playing:
		beep_countdown_audio_stream_player.stop()
		countdown_sound_playing = false  # Restablece la bandera
	countdown_30_seconds = 0
	countdown_30_seconds_label.text = "OK"
	ready_texture_button.disabled = true
	print("Jugador ha hecho clic en Listo.")
# Restablecer el estado visual a "Normal" después de procesar el clic
	ready_texture_button.disabled = true
	ready_texture_button.set_pressed(false)
	player_chosen = true
	ia_chosen = false  # Simula que la IA también ha validado automáticamente
	disable_card_interaction()
	emit_signal("ready_to_check_result")
	change_state(GameState.CHECK_RESULT)


# Función para deshabilitar la interacción en las cartas del jugador
func disable_card_interaction():
	var cards = [re_card_1, re_card_2, re_card_3, hs_card_1, hs_card_2, hs_card_3]
	for card in cards:
		card.mouse_filter = Control.MOUSE_FILTER_IGNORE
func enable_card_interaction():
	var cards = [re_card_1, re_card_2, re_card_3, hs_card_1, hs_card_2, hs_card_3]
	for card in cards:
		card.mouse_filter = Control.MOUSE_FILTER_PASS

# Función para actualizar la carta de bullying en cada turno
func update_bullying_card():
	# Verificar si hay cartas restantes en el mazo de bullying
	if deck_manager.deck_bu.size() > 0:
		# Obtener y mostrar la siguiente carta de bullying
		card_bullying = deck_manager.deck_bu.pop_back()
		display_card_bu(card_bullying, bullying_card)
		print("Carta de bullying actualizada:", card_bullying.id_carta)
	else:
		# Si no hay cartas de bullying, termina el juego
		print("No quedan cartas de bullying. Terminando el juego.")
		change_state(GameState.GAME_OVER)
# Función que se activa cuando el botón "Continuar" es presionado
