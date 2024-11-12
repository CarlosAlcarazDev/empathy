extends TextureButton


@onready var panel = $Panel2


func _ready():
	panel.visible = false

func _on_mouse_entered():
	panel.visible = true
	set_process_input(true)

# Función para mover el panel a la posición del ratón solo si está sobre el botón
func _input(event):
	if event is InputEventMouseMotion:
		# Obtener la posición global del ratón
		var global_mouse_pos = get_viewport().get_mouse_position()
		# Verificar si la posición del ratón está dentro del área del TextureButton
		if global_mouse_pos.x >= global_position.x and global_mouse_pos.x <= global_position.x + size.x and global_mouse_pos.y >= global_position.y and global_mouse_pos.y <= global_position.y + size.y:
			# Mover el panel a la posición relativa dentro del TextureButton
			var local_mouse_pos = global_mouse_pos - global_position
			panel.position = local_mouse_pos
		else:
			panel.visible = false
			set_process_input(false)
