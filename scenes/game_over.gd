extends Window

@onready var blur_overlay = $"../Overlay/BlurOverlay"


#Señal de tecla escape presionada en pantalla derrota
func _unhandled_input(event):
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_ESCAPE:
			get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")


func _on_defeat_texture_rect_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == 1 and event.pressed:
			print("Clic izquierdo detectado en TextureRect")
			get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")
