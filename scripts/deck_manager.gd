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
const DECK_RE_DATA_FILE := "res://data/deck_re.json"
const DECK_HS_DATA_FILE := "res://data/deck_hs.json"

# Array para almacenar las cartas instanciadas
var deck_re := []  
var deck_hs := []  
var deck_bu := []  

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
				if typeof(cards_data) == TYPE_ARRAY:
					#print("Los datos del JSON son de tipo array")
					create_cards_bu(cards_data) # Creamos las instancias a partir de los datos 
				else:
					print("Error: los datos del JSON no tienen el formato esperado")
				
				
			else:
				print("Error al parsear JSON:", parse_result)  # Mostramos el código de error
		else:
			print("Archivo JSON vacío o sin datos.")
		
		file.close()


# Función para crear instancias de cartas y agregarlas al deck_BU
func create_cards_bu(cards_data: Array):
	for card_data in cards_data:
		# Creamos la instancia de la carta usando el constructor de CardsRE
		if typeof(card_data) == TYPE_DICTIONARY:
			var card_instance = CardsBU.new(
				card_data.get("id", 0),
				card_data.get("nombre", ""),
				card_data.get("descripcion", ""),
				card_data.get("tipo", ""),
				card_data.get("Empatía", 0),
				card_data.get("Apoyo Emocional", 0),
				card_data.get("Intervención", 0),
				card_data.get("Comuncación", 0),
				card_data.get("Resolución de Conflictos", 0),
			)
			#AGREGA LA CARA INSTANCIADA AL DECK
			deck_bu.append(card_instance)
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
				card_data.get("Intervención", 0)
			)
			#AGREGA LA CARA INSTANCIADA AL DECK
			deck_re.append(card_instance)
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
			)
			#AGREGA LA CARA INSTANCIADA AL DECK
			deck_hs.append(card_instance)
		else:
			print("Advertencia: Un elemento de `cards_data` no es un Dictionary.")

# Función para barajar el deck de RE
func shuffle_deck_hs():
	deck_hs.shuffle()
	
	
