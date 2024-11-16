# ===============================
# Nombre del Script: register_user.gd
# Desarrollador: Carlos Alcaraz Benítez
# Fecha de Creación: 05 de Noviembre de 2024
# Descripción: Este script maneja la lógica de la pantalla de registrar usuario del juego,
# Comprueba que no exista el usuario o el email en la base de datos
# También comprueba que los datos de usuario sean correctos
# Devuelve el valor de los usuarios para la pantalla de login una vez registrado
# ===============================
# Listado de funciones
# 
#	_ready(): Cargar usuarios al iniciar
#	load_users(): Función para cargar usuarios desde el archivo JSON
#	register_user(): Función para registrar un nuevo usuario
#	show_error(message: String): # Función para mostrar un mensaje de error
#   show_success(message: String): Función para mostrar un mensaje de éxito
#	is_valid_password(password: String) -> bool: Función para validar la contraseña
#	func is_valid_email(email: String) -> bool: Función para validar el email
#	is_email_registered(email: String) -> bool: Función para verificar si el correo ya está registrado
#	is_username_registered(username: String) -> bool: Función para verificar si el correo ya está registrado
#	get_next_id() -> int: Función para obtener el próximo ID incremental
#	save_users(): Función para guardar los usuarios en el archivo JSON
#	_on_back_button_pressed(): Señal de boton volver presionada
#	_on_register_button_pressed(): Señal de boton registrar presionada
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

# Importar el módulo Time para obtener la fecha y hora actuales para guardar el dia que se registró el usuario
var time_now = Time.get_datetime_dict_from_system()

# Variable para almacenar los datos de usuarios cargados
var users = []

# Declara la expresió regular de manera global para evitar compilarlas cada vez
var email_regex := RegEx.new()

# Cargar usuarios al iniciar
func _ready():
	# Declaración de variables para las expresiones regulares del email del tipo nombre@dominio.com
	var domain_name_regex_str := "[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?"
	var domain_regex_str := domain_name_regex_str + "(?:\\." + domain_name_regex_str + ")*"
	var email_pattern := "^[a-zA-Z0-9.!#$%&'*+/=?^_\u0060{|}~-]+@" + domain_regex_str + "\\.[a-zA-Z]{2,}$"

	# Compila la expresión regular solo una vez
	email_regex.compile(email_pattern)
	# Carga los usuarios
	load_users()

# Función para cargar usuarios desde el archivo JSON
func load_users():
	var file = FileAccess.open(USER_DATA_FILE, FileAccess.READ)
	if file:
		var data = file.get_as_text()
		
		if data != "":
			# Crea una instancia de JSON y parsear el contenido del archivo
			var json = JSON.new()
			var parse_result = json.parse(data)
			
			if parse_result == OK:
				users = json.data  # Guarda los datos parseados en la variable `users`
			else:
				print("Error al parsear JSON:", parse_result)  # Imprime el código de error si falla el parseo
		else:
			print("Archivo JSON vacío o sin datos.")
		
		file.close()
	else:
		# Si el archivo no existe, crearlo y guardar un array vacío
		save_users()  # Esto inicializa el archivo con un array vacío
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
	# Comprobar que se cumplen los criterios del formato de la contraseña
	if !is_valid_password(password):
		show_error("El password debe tener mínimo 8 caracteres.")
		return
	# Comprobar que se cumplen los criterios del formato del email
	if !is_valid_email(email):
		show_error("Escribe un email correcto")
		return
		
	# Generar un nuevo ID incremental para el usuario
	var new_id = get_next_id()
	
	# Crear el nuevo usuario como un diccionario. Sigue la pauta para crear
	# la clase de usuario con los datos definidos en el diagrama de clases.
	var new_user = {
		"id": new_id,
		"username": username,
		"password": password,
		"email": email,
		"created_at": time_now
	}
	
	# Agregar el nuevo usuario a la lista de usuarios
	users.append(new_user)
	# Guardar los datos actualizados en el archivo JSON
	save_users()
	
	# Confirmación de registro
	# Guardamos en la variable Global los datos recien registrados
	# del usuario para que en la pantalla de Login aparezcan directamente
	GlobalData.user = username
	GlobalData.password = password
	GlobalData.created_at = time_now
	
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
	
# Función para validar la contraseña
func is_valid_password(password: String) -> bool:
	return password.length() >= 8
	
# Función para validar el email
func is_valid_email(email: String) -> bool:
	return email_regex.search(email) != null

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


#Señal de boton volver presionada
func _on_back_button_pressed():
	get_tree().change_scene_to_file("res://scenes/LoginScreen.tscn")

#Señal de boton registrar presionada
func _on_register_button_pressed():
	register_user()
