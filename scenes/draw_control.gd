extends Control  # Asegúrate de que el nodo es un Control o derivado

# Variable para almacenar la fuente personalizada
var font_resource: Font = preload("res://assets/fonts/Roboto-Medium.ttf")

const SAVE_FILE_PATH = "user://game.json"
# Datos para el gráfico

func _ready():
	_draw()
	
func _draw():
	var token_data = GlobalData.get_token_data()
	# Tamaño y colores del gráfico
	var bar_width = 75
	var bar_spacing = 15
	var max_height = 200  # Altura máxima de las barras
	var base_position = Vector2(50, 300)  # Posición base del gráfico
	var max_value = token_data.values().reduce(max)  # Calcular el máximo dinámicamente
	var colors = [
		Color(1, 0.42, 0.42),  # Psicológico: #FF6B6B
		Color(1, 0.62, 0.26),  # Verbal: #FF9F43
		Color(0.12, 0.56, 1),  # Ciberbullying: #1E90FF
		Color(1, 0.84, 0),     # Exclusión Social: #FFD700
		Color(0.54, 0.17, 0.89),  # Físico: #8A2BE2
		Color(1, 0.08, 0.58)   # Sexual: #FF1493
	]
	var index = 0
	var string_token: String = ""
	for token in token_data.keys():
		# Calcular la altura de la barra proporcional al valor
		var bar_height = (float(token_data[token]) / max_value) * max_height
		var _position = base_position + Vector2(index * (bar_width + bar_spacing), -bar_height)

		# Dibujar la barra
		draw_rect(Rect2(_position, Vector2(bar_width, bar_height)), colors[index % colors.size()])
		print("token 12345: ", token)
		# Formatear el token
		if token=="psicológico":
			string_token="Psicólogico"
		if token=="sexual":
			string_token="Sexual"	
		if token=="exclusión_social":
			string_token="Exclusión Social"
		if token=="verbal":
			string_token="Verbal"	
		if token=="fisico":
			string_token="Físico"
		if token=="ciberbullying":
			string_token="Ciberbullying"	

		# Dibujar el texto debajo de la barra
		var text_position = base_position + Vector2(index * (bar_width + bar_spacing), 15)
		draw_string(font_resource, text_position, string_token, HORIZONTAL_ALIGNMENT_CENTER,-1,10)
		
		# Dibujar el valor encima de la barra
		var value_position = _position + Vector2(30, -20)
		draw_string(font_resource, value_position, str(token_data[token]), HORIZONTAL_ALIGNMENT_CENTER)

		index += 1
