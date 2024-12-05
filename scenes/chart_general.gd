extends Control


var font_resource: Font = preload("res://assets/fonts/Roboto-Medium.ttf")
func _draw():
	var games_data = GlobalData.get_games_data()
	# Calcular el total sumando las categorías
	var total = games_data["wins"] + games_data["losses"] + games_data["draws"] + games_data["abandons"]

	# Centro y radio del gráfico
	var center = Vector2(300, 165)
	var radius = 100

	# Colores para cada categoría (debes definir estos previamente)
	var colors = [
		Color(0.2, 0.8, 0.2),  # Verde: Ganadas
		Color(0.8, 0.2, 0.2),  # Rojo: Perdidas
		Color(0.2, 0.2, 0.8),  # Azul: Empatadas
		Color(0.9, 0.9, 0.2)   # Amarillo: Abandonadas
	]

	# Categorías para las etiquetas
	var categories = ["Ganadas", "Perdidas", "Empatadas", "Abandonadas"]

	# Calcular ángulos
	var angles = [
		(float(games_data["wins"]) / total) * 360,
		(float(games_data["losses"]) / total) * 360,
		(float(games_data["draws"]) / total) * 360,
		(float(games_data["abandons"]) / total) * 360
	]

	# Dibujar cada trozo
	var start_angle = 0
	for i in range(angles.size()):
		var end_angle = start_angle + angles[i]
		# Dibujar trozo del gráfico
		draw_circle_arc_poly(center, radius, start_angle, end_angle, colors[i])

		# Calcular la posición del texto a la izquierda
		var text_position = Vector2(420, 125 + i * 25)  # Ajusta las posiciones verticales
		draw_string(
			font_resource,
			text_position,
			"%s: %.1f%%" % [categories[i], (angles[i] / 360) * 100],HORIZONTAL_ALIGNMENT_LEFT,-1,14,colors[i]
		)

		# Actualizar el ángulo inicial para el siguiente trozo
		start_angle = end_angle

func draw_circle_arc_poly(center, radius, angle_from, angle_to, color):
	var nb_points = 32
	var points_arc = PackedVector2Array()
	points_arc.push_back(center)
	var colors = PackedColorArray([color])

	# Generar los puntos del arco
	for i in range(nb_points + 1):
		var angle_point = deg_to_rad(angle_from + i * (angle_to - angle_from) / nb_points)
		points_arc.push_back(center + Vector2(cos(angle_point), sin(angle_point)) * radius)
	
	# Dibujar el polígono para el trozo
	draw_polygon(points_arc, colors)
