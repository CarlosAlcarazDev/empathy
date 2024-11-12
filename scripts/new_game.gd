extends Control

# Etiquetas para mostrar los contadores
@onready var countdown_30_seconds_label = $UI/Countdown30SecondsLabel
@onready var countdown_20_minutes_label = $UI/Countdown20MinutesLabel
@onready var chosen_cards_label = $UI/ChosenCardsLabel
@onready var chosen_cards_label_2 = $UI/ChosenCardsLabel2

# Constantes para los tiempos
const COUNTDOWN_30_SECONDS = 15  # En segundos
const COUNTDOWN_20_MINUTES = 20 * 60  # En segundos (20 minutos)

# Variables de tiempo
var countdown_30_seconds = COUNTDOWN_30_SECONDS
var countdown_20_minutes = COUNTDOWN_20_MINUTES

func _ready():
	# Inicializa los contadores de tiempo
	countdown_30_seconds_label.text = "%d" % countdown_30_seconds
	# Convertimos countdown_20_minutes a entero antes de realizar el formato
	countdown_20_minutes_label.text = "%d:%02d" % [int(countdown_20_minutes) / 60, int(countdown_20_minutes) % 60]




func _process(delta):
	# Actualizar el contador de 30 segundos
	if countdown_30_seconds > 0:
		countdown_30_seconds -= delta
		countdown_30_seconds_label.text = "%d" % max(countdown_30_seconds, 0)
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


func _on_volver_pressed():
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")
