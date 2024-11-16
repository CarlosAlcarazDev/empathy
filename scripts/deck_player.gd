# ===============================
##****** LÓGICA TRASLADADA A deck_manager.gd PARA GESTIONAR INTEGRALMENTE TODOS LOS MAZOS******##
# Nombre del Script: deck_player.gd
# Desarrollador: Carlos Alcaraz Benítez
# Fecha de Creación: 15 de Noviembre de 2024
# Descripción: Este script maneja la lógica responsable de manejar el mazo de cartas re y hs
# Implementa la logica para:
# Cargar las cartas desde el archivo deck_re.json
# Cargar las cartas desde el archivo deck_hs.json
# Crear instancias de CardsRE con la información de cada carta
# Crear instancias de CardsHS con la información de cada carta
# Barajar el mazo de cartas re y almacenarla en una lista
# Barajar el mazo de cartas hs y almacenarla en una lista

extends Control
# Ruta del archivo JSON donde se almacenan los datos del mazo de re
# Ruta del archivo JSON donde se almacenan los datos del mazo de hs
const DECK_RE_DATA_FILE := "res://data/deck_re.json"
const DECK_HS_DATA_FILE := "res://data/deck_hs.json"

# Arrays para almacenar las cartas instanciadas
var deck_re := []  
var deck_hs := []  

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
		# Crea la instancia de la carta usando el constructor de CardsRE
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
	
	
# Función para cargar el JSON y crear las cartas de hs
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


# Función para crear instancias de cartas y agregarlas al deck_hs
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
