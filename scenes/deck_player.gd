#Nodo responsable de manejar la baraja de cartas.
#Implementamos la logica para
#cargar las cartas desde el archivo deck_RE.json
#crear instancias de CardsRE con la información de cada carta
#Barajar el mazo de cartas y almacenarla en una ista

extends Control

const DECK_RE_DATA_FILE := "res://data/deck_re.json"
const DECK_HS_DATA_FILE := "res://data/deck_hs.json"

var deck_re := []  # Aquí se almacenar las cartas instanciadas
var deck_hs := []  # Aquí se almacenar las cartas instanciadas

# Función para cargar el JSON y crear las cartas
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
		#print("typeofdata card_Data")
		#print(typeof(card_data))
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
	
	
# Función para cargar el JSON y crear las cartas
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


# Función para crear instancias de cartas y agregarlas al deck_re
func create_cards_hs(cards_data: Array):
	
	for card_data in cards_data:
		# Creamos la instancia de la carta usando el constructor de CardsRE
		#print("typeofdata card_Data")
		#print(typeof(card_data))
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
