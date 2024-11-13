extends Control

# Etiquetas para mostrar los contadores

@onready var countdown_20_minutes_label = $UI/Countdown20MinutesLabel
@onready var chosen_cards_label = $UI/ChosenCardsLabel
@onready var chosen_cards_label_2 = $UI/ChosenCardsLabel2
@onready var countdown_30_seconds_label = $UI/Countdown30SecondsLabel
@onready var beep_countdown_audio_stream_player = $UI/BeepCountdownAudioStreamPlayer

@onready var deck_player = $DeckPlayer
@onready var re_card_1 = $DeckPlayer/RECard1
@onready var re_card_2 = $DeckPlayer/RECard2
@onready var re_card_3 = $DeckPlayer/RECard3
@onready var hs_card_1 = $DeckPlayer/HSCard1
@onready var hs_card_2 = $DeckPlayer/HSCard2
@onready var hs_card_3 = $DeckPlayer/HSCard3

@onready var deck_bullying = $DeckBullying
@onready var bullying_card = $DeckBullying/BullyingCard


# Constantes para los tiempos
const COUNTDOWN_30_SECONDS = 15  # En segundos
const COUNTDOWN_20_MINUTES = 20 * 60  # En segundos (20 minutos)

# Variables de tiempo
var countdown_30_seconds = COUNTDOWN_30_SECONDS
var countdown_20_minutes = COUNTDOWN_20_MINUTES
# Bandera para controlar el sonido de cuenta regresiva
var countdown_sound_playing = false  # Se asegura de que el sonido solo se reproduzca una vez


func _ready():
	# Inicializa los contadores de tiempo
	countdown_30_seconds_label.text = "%d" % countdown_30_seconds
	# Convertimos countdown_20_minutes a entero antes de realizar el formato
	countdown_20_minutes_label.text = "%d:%02d" % [int(countdown_20_minutes) / 60, int(countdown_20_minutes) % 60]
	deck_player.load_cards_re_from_json()
	deck_player.shuffle_deck_re()
	deck_player.load_cards_hs_from_json()
	deck_player.shuffle_deck_hs()
	deck_bullying.load_cards_bu_from_json()
	deck_bullying.shuffle_deck_bu()
	
	for card in deck_player.deck_re:
		print(card.id_carta)
	for card in deck_player.deck_hs:
		print(card.nombre)
	for card in deck_bullying.deck_bu:
		print(card.nombre)
 	# Repartir las primeras 3 cartas a los slots de la interfaz
	deal_initial_card()


func _process(delta):
	# Actualizar el contador de 30 segundos
	if countdown_30_seconds > 0:
		countdown_30_seconds -= delta
	   # Mostrar "Listo" cuando queden más de 10 segundos
		if countdown_30_seconds > 11:
			countdown_30_seconds_label.text = "Listo"
		else:
			# Mostrar la cuenta regresiva cuando queden 10 segundos o menos
			countdown_30_seconds_label.text = "%d" % max(int(countdown_30_seconds), 0)

			# Empezar el sonido de cuenta regresiva cuando quedan 10 segundos
			if countdown_30_seconds <= 11 and not countdown_sound_playing:
				
				var volume_db = lerp(-80, 0, GameConfig.sfx_volume / 100.0)
				beep_countdown_audio_stream_player.volume_db = volume_db
				beep_countdown_audio_stream_player.play()  # Reproduce el sonido
				countdown_sound_playing = true  # Asegurarse de no empezar el sonido más de una vez

	else:
		# Cuando se acabe el tiempo de 30 segundos MUESTRA LAS CARTAS
		show_chosen_cards()

	# Actualizar el contador de 20 minutos
	if countdown_20_minutes > 0:
		countdown_20_minutes -= delta
		countdown_20_minutes_label.text = "%d:%02d" % [int(countdown_20_minutes) / 60, int(countdown_20_minutes) % 60]


# Función para mostrar las cartas elegidas al acabar los 30 segundos
func show_chosen_cards():
	# Muestra el valor del number_card_label del nodo guardado
	var number_card_label = GlobalData.current_card_in_target_positionRE.get_node("NumberCardLabel")
	var label_text = number_card_label.text
	print ("label_text Re")
	print (label_text)
	var number_card_label2 = GlobalData.current_card_in_target_positionHS.get_node("NumberCardLabel")
	var label_text2 = number_card_label2.text
	print ("label_text2 HS")
	print (label_text2)
	chosen_cards_label.text = label_text
	chosen_cards_label_2.text = label_text2


#funcion para repartir las tres cartas iniciales a los nodos RECard1, RECard2, RECard3
func deal_initial_card():
		# Repartir tres cartas asegurándonos de que haya suficientes cartas
	ensure_deck_re_has_cards(3)
	ensure_deck_hs_has_cards(3)

	# Extraemos los diccionarios y los convertimos en objetos CardsRE
	var card1 = deck_player.deck_re.pop_back()
	var card2 = deck_player.deck_re.pop_back()
	var card3 = deck_player.deck_re.pop_back()
	var card4 = deck_player.deck_hs.pop_back()
	var card5 = deck_player.deck_hs.pop_back()
	var card6 = deck_player.deck_hs.pop_back()
	
	var card_bullying = deck_bullying.deck_bu.pop_back()
	
	display_card_re(card1, re_card_1)
	display_card_re(card2, re_card_2)
	display_card_re(card3, re_card_3)
	display_card_hs(card4, hs_card_1)
	display_card_hs(card5, hs_card_2)
	display_card_hs(card6, hs_card_3)

	display_card_bu(card_bullying, bullying_card)

# Función para asegurar que haya al menos una cantidad mínima de cartas en el deck
func ensure_deck_re_has_cards(min_cards: int):
	if deck_player.deck_re.size() < min_cards:
		print("No hay suficientes cartas en el deck. Regenerando la pila...")
		deck_player.load_cards_from_json()
		deck_player.shuffle_deck()

func ensure_deck_hs_has_cards(min_cards: int):
	if deck_player.deck_hs.size() < min_cards:
		print("No hay suficientes cartas en el deck. Regenerando la pila...")
		deck_player.load_cards_from_json()
		deck_player.shuffle_deck()

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
		"exclusion social":
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
