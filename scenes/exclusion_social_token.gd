
extends Control


# Define las constantes escalas de la carta
const NORMAL_SCALE = Vector2(0.2, 0.2)
const HOVER_SCALE = Vector2(0.75, 0.75)

# Variables para guardar la posicion original de la carta
var _position = position
# Variable para almacenar el z_index original
var original_z_index = 0  

# Función para conectar las señales de entrar y salir el mouse y doble click, define escala, posicion e indice
func _ready():
	connect("mouse_entered", Callable(self, "_on_mouse_entered"))
	connect("mouse_exited", Callable(self, "_on_mouse_exited"))

	scale = NORMAL_SCALE

	# Almacena el z_index original para restaurarlo después del arrastre
	original_z_index = z_index

# Señal mouse ha entrado. Escala la imagen y la coloca encima de la actual
func _on_mouse_entered():

	position.y = _position.y - 250
	
	scale = HOVER_SCALE
	z_index = 10

# Señal mouse ha salido. Restaura la escala y posición originales solo si la carta no ha sido movida
func _on_mouse_exited():
	scale = NORMAL_SCALE
	z_index = original_z_index
	position = _position
