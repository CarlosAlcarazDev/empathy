##Nodo responsable de manejar la baraja de cartas.
##Implementamos la logica para
##cargar las cartas desde el archivo deck_BU.json
##crear instancias de CardsBU con la información de cada carta
##Barajar el mazo de cartas y almacenarla en una ista
#
extends Control
#
#
const DECK_BU_DATA_FILE := "res://data/deck_bu.json"
#
var deck_bu := []  # Aquí se almacenar las cartas instanciadas
#var deck_hs := []  # Aquí se almacenar las cartas instanciadas
#
## Función para cargar el JSON y crear las cartas
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


# Función para crear instancias de cartas y agregarlas al deck_re
func create_cards_bu(cards_data: Array):
	
	for card_data in cards_data:
		# Creamos la instancia de la carta usando el constructor de CardsRE
		#print("typeofdata card_Data")
		#print(typeof(card_data))
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

# Función para barajar el deck de RE
func shuffle_deck_bu():
	deck_bu.shuffle()

	
