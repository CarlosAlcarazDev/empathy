# ===============================
# Nombre del Script: RegisterUser.gd
# Desarrollador: Carlos Alcaraz Benítez
# Fecha de Creación: 05 de Noviembre de 2024
# Descripción: Este script maneja la lógica de la pantalla de registrar usuario del juego,
# Comprueba que no exista el usuario o el email en la base de datos
# 
# ===============================

extends Control



# Ruta del archivo JSON donde se almacenan los datos de usuario
const USER_DATA_FILE := "user://users.json"

# Referencias a los nodos de la escena
@onready var username_input = $VBoxContainer/UsernameInput
@onready var password_input = $VBoxContainer/PasswordInput
@onready var email_input = $VBoxContainer/EmailInput
@onready var info_label = $VBoxContainer/InfoLabel
@onready var register_button = $RegisterButton


# Variable para almacenar los datos de usuarios cargados
var users = []

# Cargar usuarios al iniciar
func _ready():
	load_users()

# Función para cargar usuarios desde el archivo JSON
func load_users():
	var file = FileAccess.open(USER_DATA_FILE, FileAccess.READ)
	if file:
		var data = file.get_as_text()
		
		if data != "":
			# Crear una instancia de JSON y parsear el contenido del archivo
			var json = JSON.new()
			var parse_result = json.parse(data)
			
			if parse_result == OK:
				users = json.data  # Guardamos los datos parseados en la variable `users`
			else:
				print("Error al parsear JSON:", parse_result)  # Imprimimos el código de error si falla el parseo
		else:
			print("Archivo JSON vacío o sin datos.")
		
		file.close()
	else:
		# Si el archivo no existe, crearlo y guardar un arreglo vacío
		save_users()  # Esto inicializa el archivo con un arreglo vacío
		print("No se encontró el archivo JSON, se creó uno nuevo.")

# Función para registrar un nuevo usuario
func register_user():
	var username = username_input.text
	var password = password_input.text
	var email = email_input.text
	
	# Validación simple de entrada de datos
	if username == "" or password == "" or email == "":
		show_error("Todos los campos son obligatorios.")
		return
	# Comprobar si el correo electrónico ya está registrado
	if is_email_registered(email):
		show_error("El correo ya está registrado. Usa otro.")
		return
	# Comprobar si el nombre de usuario ya está registrado
	if is_username_registered(username):
		show_error("El nombre de usuario ya está registrado. Usa otro.")
		return
	# Generar un nuevo ID incremental para el usuario
	var new_id = get_next_id()
	
	# Crear el nuevo usuario como un diccionario
	var new_user = {
		"id": new_id,
		"username": username,
		"password": password,
		"email": email
	}
	
	# Agregar el nuevo usuario a la lista de usuarios
	users.append(new_user)
	# Guardar los datos actualizados en el archivo JSON
	save_users()
	
	# Confirmación de registro
 # Mostrar mensaje de éxito
	show_success("Usuario registrado con éxito.")

	
	# Función para mostrar un mensaje de error
func show_error(message: String):
	info_label.text = message
	info_label.modulate = Color(1, 0, 0)  # Cambia el color a rojo para indicar error
	info_label.visible = true
	#error_timer.start()

# Función para mostrar un mensaje de éxito
func show_success(message: String):
	register_button.disabled = true
	info_label.text = message
	info_label.modulate = Color(0, 1, 0)  # Cambia el color a verde para indicar éxito
	info_label.visible = true
	await get_tree().create_timer(2.5).timeout
	get_tree().change_scene_to_file("res://scenes/LoginScreen.tscn")
	
# Función para verificar si el correo ya está registrado
func is_email_registered(email: String) -> bool:
	for user in users:
		if user.has("email") and user["email"] == email:
			return true
	return false

# Función para verificar si el correo ya está registrado
func is_username_registered(username: String) -> bool:
	for user in users:
		if user.has("username") and user["username"] == username:
			return true
	return false
	
# Función para obtener el próximo ID incremental
func get_next_id() -> int:
	var max_id = 0
	for user in users:
		if user.has("id") and user["id"] > max_id:
			max_id = user["id"]
	return max_id + 1

# Función para guardar los usuarios en el archivo JSON
func save_users():
	var file = FileAccess.open(USER_DATA_FILE, FileAccess.WRITE)
	if file:
		var json_string = JSON.stringify(users, "\t") #\t formateamos el json
		if json_string == null:
			print("Error al convertir usuarios a JSON.")
		else:
			file.store_string(json_string)
			print("Usuarios guardados correctamente.")
		file.close()
	else:
		print("No se pudo abrir el archivo JSON para escribir.")



func _on_back_button_pressed():
	get_tree().change_scene_to_file("res://scenes/LoginScreen.tscn")


func _on_register_button_pressed():
	register_user()
