# ===============================
# Nombre del Script: login_screen.gd
# Desarrollador: Carlos Alcaraz Benítez
# Fecha de Creación: 04 de Noviembre de 2024
# Descripción: Este script maneja la lógica de la pantalla de login del juego,
# incluyendo el inicio y la creación de un nuevo usuario.
# Se muestran imagenes aleatoriamente cada vez que se carga la escena.

#Listado de funciones:
	#_ready(): Inicializa el nodo al cargarlo en la escena
	#get_random_texture_index() -> int: #Obtiene una imagen aleatoria teniendo en cuenta la última textura que se cargó para no repetir
	#save_last_texture_index(): Guarda la imagen para saber cúal ha sido la ultima utilizada
	#load_last_texture_index(): Carga la imagen última utilizada
	#load_last_texture_index(): Carga la imagen última utilizada
	#load_users():# Función para cargar usuarios desde el archivo JSON
	#login(): # Función para iniciar sesión
	#show_error(message: String): #Función para mostrar mensaje de error
	#show_success(message: String): # Función para mostrar un mensaje de éxito
	#_on_quit_button_pressed(): # Señal de botón salir presionada
	#_on_login_button_pressed(): #Señal boton login presionada, ejecuta un sonido.
	#_on_create_button_pressed(): #Señal de boton registrar usuario presionada
	#_on_audio_stream_player_finished(): #Señal sonido finalizado, carga la función login()
	#_on_password_input_text_submitted(): #Señal enter en password presionado, ejecuta un sonido.
# ===============================
extends Control
	
# Referencias a los nodos de la escena

@onready var audio_stream_player = $AudioStreamPlayer
@onready var texture_rect = $TextureRect
@onready var username_input = $VBoxContainer/UsernameInput
@onready var password_input = $VBoxContainer/PasswordInput
@onready var info_label = $InfoLabel
@onready var login_button = $HBoxContainer/LoginButton


# Precarga las texturas que se mostrarán aleatoriamente
const TEXTURES = [
	preload("res://assets/ui/backgrounds/login_bg_1.png"),
	preload("res://assets/ui/backgrounds/login_bg_2.png"),
	preload("res://assets/ui/backgrounds/login_bg_3.png"),
	preload("res://assets/ui/backgrounds/login_bg_4.png")
]
#Ruta del archivo JSON donde se almacen las texturas
const LAST_TEXTURE = "user://last_texture_index.txt"
# Ruta del archivo JSON donde se almacenan los datos de usuario
const USER_DATA_FILE := "user://users.json"

# Índice de la última textura seleccionada
var last_texture_index = -1  


func _ready():
	
	# En caso de venir de la escena de registro se añaden los datos del  
	# nuevo usuario al formulario de login para faciliar su inicio de sesión
	username_input.text = GlobalData.user
	password_input.text = GlobalData.password
	
	# Inicializa el generador de números aleatorios
	randomize()  
	
	# Carga el último índice de textura desde el archivo
	load_last_texture_index()
	
	# Selecciona un índice aleatorio de la lista que no sea igual al último seleccionado
	var random_texture_index = get_random_texture_index()
	
	# Asigna la textura aleatoria al TextureRect
	texture_rect.texture = TEXTURES[random_texture_index]
	
	# Actualiza el índice de la última textura seleccionada
	last_texture_index = random_texture_index
	
	# Guarda el nuevo índice de textura en el archivo
	save_last_texture_index()
	
	# Configura el tamaño fijo de la imagen.
	texture_rect.size_flags_horizontal = Control.SIZE_SHRINK_END - 100
	texture_rect.size_flags_vertical = Control.SIZE_SHRINK_CENTER - 100
	
	# Carga los usuarios en la variable users[]
	load_users()
	
var users = []

# Obtiene una imagen aleatoria teniendo en cuenta la última textura que se cargó para no repetir
func get_random_texture_index() -> int:
	var new_index = randi() % TEXTURES.size()
	#print("last_texture_index, new_index:", last_texture_index, new_index)
	while new_index == last_texture_index:
		new_index = randi() % TEXTURES.size()
		#print("last_texture_index, new_index:", last_texture_index, new_index)
	return new_index

# Guarda la imagen para saber cúal ha sido la ultima utilizada
func save_last_texture_index():
	var file = FileAccess.open(LAST_TEXTURE, FileAccess.ModeFlags.WRITE)
	if file:
		file.store_var(last_texture_index)
		file.close()

# Carga la imagen última utilizada
func load_last_texture_index():
	var file = FileAccess.open(LAST_TEXTURE, FileAccess.ModeFlags.READ)
	if file:
		if FileAccess.file_exists(LAST_TEXTURE):
			last_texture_index = file.get_var()
			file.close()
		else:
			last_texture_index = -1

# Función para cargar usuarios desde el archivo JSON
func load_users():
	var file = FileAccess.open(USER_DATA_FILE, FileAccess.READ)
	if file:
		var data = file.get_as_text()
		if data != "":
			# Crear una instancia de JSON
			var json = JSON.new()
			var parse_result = json.parse(data)
			
			if parse_result == OK:
				# Accedemos a los datos parseados con `json.data`
				users = json.data 
			else:
				# Mostramos el código de error
				print("Error al parsear JSON:", parse_result)  
		else:
			print("Archivo JSON vacío o sin datos.")
		
		file.close()

# Función para iniciar sesión
func login():
	var username = username_input.text
	var password = password_input.text

	for user in users:
		if user["username"] == username and user["password"] == password:
			print("Inicio de sesión exitoso!")
			show_success("Inicio de sesión exitoso")

			# Se utilizan la variable GlobalData como un Singleton
			# que se configura en Autoload de la configuración del Proyecto
			# de esta manera podemos pasar la información del usuario cargado
			# correctamente entre las escenas.
			# Debemos hacer esto, ya que Godot no permite el paso de variables entre escenas
			
			GlobalData.user = username
			GlobalData.id = user["id"]
			GlobalData.created_at = user["created_at"]
			print(GlobalData.user)
			print(GlobalData.id)
			print(GlobalData.created_at.year)
			#Espera 2.5 segundos a cargar la siguiente escena
			await get_tree().create_timer(2.5).timeout
			get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")
			return
			
	show_error("Usuario o Contraseña incorrectos")

#Función para mostrar mensaje de error
func show_error(message: String):
	info_label.text = message
	info_label.modulate = Color(1, 0, 0)  # Cambia el color a rojo para indicar error
	info_label.visible = true

# Función para mostrar un mensaje de éxito
func show_success(message: String):
	login_button.disabled = true
	info_label.text = message
	info_label.modulate = Color(0, 1, 0)  # Cambia el color a verde para indicar éxito
	info_label.visible = true
	

# Señal de botón salir presionada
func _on_quit_button_pressed():
	get_tree().quit(0)

#Señal boton login presionada, ejecuta un sonido.
func _on_login_button_pressed():
	audio_stream_player.playing = true
	

#Señal de boton registrar usuario presionada
func _on_create_button_pressed():
	get_tree().change_scene_to_file("res://scenes/RegisterUser.tscn")

#Señal sonido finalizado, carga la función login()
func _on_audio_stream_player_finished():
	login()
	
#Señal enter en password presionado, ejecuta un sonido.
func _on_password_input_text_submitted():
	audio_stream_player.playing = true
