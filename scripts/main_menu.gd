extends Control


@onready var user_label = $UserLabel
@onready var id_label = $IDLabel



# Called when the node enters the scene tree for the first time.
func _ready():
	id_label.text = "ID: " + str(GlobalData.id)
	user_label.text = "Usuario: " + GlobalData.user
	
	



func _on_button_pressed():
	get_tree().change_scene_to_file("res://scenes/LoginScreen.tscn")


func _on_button_2_pressed():
	get_tree().quit()
