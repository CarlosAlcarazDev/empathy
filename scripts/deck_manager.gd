# ===============================
# Nombre del Script: deck_manager.gd
# Desarrollador: Carlos Alcaraz Benítez
# Fecha de Creación: 10 de Noviembre de 2024
# Descripción: Este script maneja la lógica responsable de manejar los mazos de cartas bu, hs, re
# Implementa la logica para:
# Cargar las cartas desde el archivo deck_BU.json
# Cargar las cartas desde el archivo deck_HS.json
# Cargar las cartas desde el archivo deck_RE.json
# Crear instancias de CardsBU con la información de cada carta
# Crear instancias de CardsHS con la información de cada carta
# Crear instancias de CardsRE con la información de cada carta
# Barajar el mazo de cartas BU y almacenarla en una lista
# Barajar el mazo de cartas HS y almacenarla en una lista
# Barajar el mazo de cartas RE y almacenarla en una lista

extends Control

# Ruta del archivo JSON donde se almacenan los datos del mazo de re
# Ruta del archivo JSON donde se almacenan los datos del mazo de hs
# Ruta del archivo JSON donde se almacenan los datos del mazo de BU
const DECK_BU_DATA_FILE := "res://data/deck_bu.json"
const STATS_BU_DATA_FILE := "res://data/stats_tipos_bullying.json"
const DECK_RE_DATA_FILE := "res://data/deck_re_updated.json"
const DECK_HS_DATA_FILE := "res://data/deck_hs_updated.json"

# Array para almacenar las cartas instanciadas
var deck_re := []  
var deck_hs := []  
var deck_bu := []  
var raw_deck_re := []
var raw_deck_hs := []
var raw_deck_bu := []

# Función para cargar el JSON y crear las cartas de BU
func load_cards_bu_from_json():
	var file = FileAccess.open(DECK_BU_DATA_FILE, FileAccess.READ)
	if file:
		var data = file.get_as_text()
		if data != "":
			# Crear una instancia de JSON
			var json = JSON.new()
			var parse_result = json.parse(data)
							
			if parse_result == OK:
			
				var cards_data = json.data  # Accedemos al resultado del parseo
				
				var stats_bu_data = load_stats_bu_data()
				if typeof(cards_data) == TYPE_ARRAY:
					#print("Los datos del JSON son de tipo array")
					create_cards_bu(cards_data, stats_bu_data) # Creamos las instancias a partir de los datos y los estadísticas  
				else:
					print("Error: los datos del JSON no tienen el formato esperado")
				
				
			else:
				print("Error al parsear JSON:", parse_result)  # Mostramos el código de error
		else:
			print("Archivo JSON vacío o sin datos.")
		
		file.close()

# Función para cargar las estadísticas desde el archivo JSON
func load_stats_bu_data() -> Dictionary:
	var file = FileAccess.open(STATS_BU_DATA_FILE, FileAccess.READ)
	if file:
		var data = file.get_as_text()
		if data != "":
			# Crear una instancia de JSON
			var json = JSON.new()
			var parse_result = json.parse(data)
							
			if parse_result == OK:
				return json.data
			else:
				print("Error al parsear el archivo JSON de estadísticas: ", parse_result)
		else:
			print("Archivo de estadísticas vacío o sin datos: ", STATS_BU_DATA_FILE)
	else:
		print("No se pudo abrir el archivo de estadísticas: ", STATS_BU_DATA_FILE)
	
	# Devolver un diccionario vacío como valor predeterminado
	return {}


# Función para crear instancias de cartas y agregarlas al deck_BU
func create_cards_bu(cards_data: Array, stats_bu_data: Dictionary):
	for card_data in cards_data:        # Verificar si la entrada es un diccionario
		if typeof(card_data) == TYPE_DICTIONARY:
			# Obtener el tipo de bullying de la carta y capitalizar
			var tipo = card_data.get("tipo", "").capitalize()
			
			# Obtener las estadísticas asociadas al tipo de bullying
			var tipo_stats = stats_bu_data.get(tipo, {
				"Empatía": 0,
				"Apoyo Emocional": 0,
				"Intervención": 0,
				"Comunicación": 0,
				"Resolución de Conflictos": 0,
				"Enfoque principal": "Sin datos",
				"Necesidades clave": "Sin datos"
			})
			
			# Extraer los valores específicos
			var empatia = tipo_stats.get("Empatía", 0)
			var apoyo_emocional = tipo_stats.get("Apoyo Emocional", 0)
			var intervencion = tipo_stats.get("Intervención", 0)
			var comunicacion = tipo_stats.get("Comunicación", 0)
			var resolucion_de_conflictos = tipo_stats.get("Resolución de Conflictos", 0)
			var enfoque_principal = tipo_stats.get("Enfoque principal", "Sin datos")
			var necesidades_clave = tipo_stats.get("Necesidades clave", "Sin datos")

			# Crear la instancia de la carta
			var card_instance = CardsBU.new(
				card_data.get("id", 0),
				card_data.get("nombre", ""),
				card_data.get("descripcion", ""),
				enfoque_principal,
				necesidades_clave,
				card_data.get("tipo", ""),
				empatia,
				apoyo_emocional,
				intervencion,
				comunicacion,
				resolucion_de_conflictos
			)

			# Verificar que los datos se están pasando correctamente
			print("Creando carta: ", card_instance.nombre)
			print("Enfoque principal: ", card_instance.enfoque_principal)
			print("Necesidades clave: ", card_instance.necesidades_clave)
			#AGREGA LA CARA INSTANCIADA AL DECK
			deck_bu.append(card_instance)
			raw_deck_bu.append(card_instance)
		else:
			print("Advertencia: Un elemento de `cards_data` no es un Dictionary.")

# Función para barajar el deck de BU
func shuffle_deck_bu():
	deck_bu.shuffle()

# Función para cargar el JSON y crear las cartas de re
func load_cards_re_from_json():
	var file = FileAccess.open(DECK_RE_DATA_FILE, FileAccess.READ)
	if file:
		var data = file.get_as_text()
		if data != "":
			# Crear una instancia de JSON
			var json = JSON.new()
			var parse_result = json.parse(data)
							
			if parse_result == OK:
			
				var cards_data = json.data  # Accedemos al resultado del parseo
				if typeof(cards_data) == TYPE_ARRAY:
					#print("Los datos del JSON son de tipo array")
					create_cards_re(cards_data) # Creamos las instancias a partir de los datos 
				else:
					print("Error: los datos del JSON no tienen el formato esperado")
				
				
			else:
				print("Error al parsear JSON:", parse_result)  # Mostramos el código de error
		else:
			print("Archivo JSON vacío o sin datos.")
		
		file.close()


# Función para crear instancias de cartas y agregarlas al deck_re
func create_cards_re(cards_data: Array):
	
	for card_data in cards_data:
		# Creamos la instancia de la carta usando el constructor de CardsRE
		if typeof(card_data) == TYPE_DICTIONARY:
			var card_instance = CardsRE.new(
				card_data.get("idCarta", 0),
				card_data.get("Nombre", ""),
				card_data.get("Descripción", ""),
				card_data.get("Empatía", 0),
				card_data.get("Apoyo Emocional", 0),
				card_data.get("Intervención", 0),
				card_data.get("Contexto en el Juego", ""),
				card_data.get("Afinidad", {
					"Sexual": "Baja",
					"Verbal": "Baja",
					"Físico": "Baja",
					"Ciberbullying": "Baja",
					"Psicológico": "Baja",
					"Exclusión Social": "Baja"
				})  # Valor por defecto en caso de que no exista el campo "Afinidad"
			)
			#AGREGA LA CARA INSTANCIADA AL DECK
			deck_re.append(card_instance)
			raw_deck_re.append(card_instance)
		else:
			print("Advertencia: Un elemento de `cards_data` no es un Dictionary.")
	
# Función para barajar el deck de RE
func shuffle_deck_re():
	deck_re.shuffle()
	
	
# Función para cargar el JSON y crear las cartas de HS
func load_cards_hs_from_json():
	var file = FileAccess.open(DECK_HS_DATA_FILE, FileAccess.READ)
	if file:
		var data = file.get_as_text()
		if data != "":
			# Crear una instancia de JSON
			var json = JSON.new()
			var parse_result = json.parse(data)
							
			if parse_result == OK:
			
				var cards_data = json.data  # Accedemos al resultado del parseo
				if typeof(cards_data) == TYPE_ARRAY:
					#print("Los datos del JSON son de tipo array")
					create_cards_hs(cards_data) # Creamos las instancias a partir de los datos 
				else:
					print("Error: los datos del JSON no tienen el formato esperado")
				
				
			else:
				print("Error al parsear JSON:", parse_result)  # Mostramos el código de error
		else:
			print("Archivo JSON vacío o sin datos.")
		
		file.close()


# Función para crear instancias de cartas y agregarlas al deck_HS
func create_cards_hs(cards_data: Array):
	
	for card_data in cards_data:
		# Creamos la instancia de la carta usando el constructor de CardsRE
		if typeof(card_data) == TYPE_DICTIONARY:
			var card_instance = CardsHS.new(
				card_data.get("idCarta", 0),
				card_data.get("Nombre", ""),
				card_data.get("Comunicación", 0),
				card_data.get("Resolución de Conflictos", 0),
				card_data.get("Descripción", ""),
				card_data.get("Contexto en el Juego", ""),
				card_data.get("Afinidad", {
					"Sexual": "Baja",
					"Verbal": "Baja",
					"Físico": "Baja",
					"Ciberbullying": "Baja",
					"Psicólogico": "Baja",
					"Exclusión Social": "Baja"
				})   # Valor por defecto en caso de que no exista el campo "Afinidad"
			)
			#AGREGA LA CARA INSTANCIADA AL DECK
			deck_hs.append(card_instance)
			raw_deck_hs.append(card_instance)
		else:
			print("Advertencia: Un elemento de `cards_data` no es un Dictionary.")

# Función para barajar el deck de RE
func shuffle_deck_hs():
	deck_hs.shuffle()
	
# Función para buscar una carta por ID del mazo RE
func get_card_re_by_id(card_id: int) -> CardsRE:
	print("Contenido de deck_re:")
	var i = 1
	for card in raw_deck_re:
		
		if card is CardsRE:
			print(i)
			print("Carta - ID:", card.id_carta, "Nombre:", card.nombre)
			i = i+1
		else:
			print("Elemento en deck_re no es una instancia de CardsRE:", card)
	for card in raw_deck_re:
		if int(card.id_carta) == int(card_id):  # Comparar el ID de la carta
			print("get_carta_dentro del for", card.nombre)
			return card
	return  # Retorna un Dictionary vacío si no se encuentra la carta

# Función para buscar una carta por ID del mazo HS
func get_card_hs_by_id(card_id: int) -> CardsHS:
	print("Contenido de deck_re:")
	var i = 1
	for card in raw_deck_hs:
		
		if card is CardsHS:
			print(i)
			print("Carta - ID:", card.id_carta, "Nombre:", card.nombre)
			i = i+1
		else:
			print("Elemento en deck_hs no es una instancia de Cardshs:", card)
	for card in raw_deck_hs:
		if int(card.id_carta) == int(card_id):  # Comparar el ID de la carta
			print("get_carta_dentro del for", card.nombre)
			return card
	return  # Retorna un Dictionary vacío si no se encuentra la carta

# Función para buscar una carta por ID del mazo BU
func get_card_bu_by_id(card_id: int) -> CardsBU:
	print("Contenido de deck_BU:")
	var i = 1
	for card in raw_deck_bu:
		
		if card is CardsBU:
			print(i)
			print("Carta - ID:", card.id_carta, "Nombre:", card.nombre)
			i = i+1
		else:
			print("Elemento en deck_re no es una instancia de CardsRE:", card)
	for card in raw_deck_bu:
		if int(card.id_carta) == int(card_id):  # Comparar el ID de la carta
			print("get_carta_dentro del for", card.nombre)
			return card
	return  # Retorna un Dictionary vacío si no se encuentra la carta
