extends Button

# Nodo Timer y Label para el mensaje de información


@onready var info_label = $"../../../../InfoLabel"

@onready var timer = $"../Timer"

func _ready():
	# Conectamos las señales del botón
	self.connect("mouse_entered", Callable(self._on_mouse_entered))
	self.connect("mouse_exited", Callable(self._on_mouse_exited))
	
	# Ocultamos la etiqueta de información al inicio
	info_label.visible = false

func _on_mouse_entered():
	# Reiniciamos y comenzamos el temporizador cuando el ratón entra en el botón
	timer.start()

func _on_mouse_exited():
	# Detenemos el temporizador y ocultamos el mensaje si el ratón sale
	timer.stop()
	info_label.visible = false


func _on_timer_timeout():
	info_label.visible = true
