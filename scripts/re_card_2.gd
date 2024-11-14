extends Control

# Señal que se emitirá cuando la carta sea seleccionada
signal card_chosen_re(card_id)

@onready var re_card_2 = $"."
@onready var number_card_label = $NumberCardLabel

const NORMAL_SCALE = Vector2(0.13, 0.13)
const HOVER_SCALE = Vector2(0.22, 0.22)
const TARGET_SCALE = Vector2(0.1, 0.1)
var _position = position
var original_z_index = 0  # Variable para almacenar el z_index original
# Define la posición a la que se moverá la carta
const TARGET_POSITION = Vector2(601, 494)   
const ORIGINAL_POSITION = Vector2(557.3, 804)
var is_moved = false  # Bandera para verificar si la carta ha sido movida

func _ready():
	connect("mouse_entered", Callable(self, "_on_mouse_entered"))
	connect("mouse_exited", Callable(self, "_on_mouse_exited"))
	connect("gui_input", Callable(self, "on_gui_input"))

	scale = NORMAL_SCALE
	position = ORIGINAL_POSITION
	# Almacena el z_index original para restaurarlo después del arrastre
	original_z_index = z_index

func _on_mouse_entered():
	if not is_moved:
		position.y = _position.y - 190
		scale = HOVER_SCALE
		z_index = 10

func _on_mouse_exited():
	# Restaura la escala y posición originales solo si la carta no ha sido movida
	if not is_moved:
		scale = NORMAL_SCALE
		position = ORIGINAL_POSITION
		z_index = original_z_index

func on_gui_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.double_click:
		# Si hay una carta en TARGET_POSITION, restáurala a su posición original
		if GlobalData.current_card_in_target_positionRE != null and GlobalData.current_card_in_target_positionRE != self:
			GlobalData.current_card_in_target_positionRE.move_to_original_position()

		# Mueve esta carta a TARGET_POSITION
		is_moved = true  # Marca la carta como movida para que no vuelva al estado original
		position = TARGET_POSITION
		scale = TARGET_SCALE
		z_index = 4
		GlobalData.current_card_in_target_positionRE = self  # Actualiza la carta actual como la que está en TARGET_POSITION
		print("Carta movida a TARGET_POSITION: ", self)
		GlobalData.id_current_card_in_target_positionRE = number_card_label.text
						# Emitir la señal indicando que la carta fue seleccionada
		emit_signal("card_chosen_re", number_card_label.text)


func move_to_original_position():
	# Método para mover esta carta de vuelta a su posición original
	position = ORIGINAL_POSITION
	scale = NORMAL_SCALE
	z_index = original_z_index
	is_moved = false
	# Limpia current_card_in_target_position si esta carta está en la posición objetivo
	if GlobalData.current_card_in_target_positionRE == self:
		GlobalData.current_card_in_target_positionRE = null
	print("Carta devuelta a la posición original: ", self)
