#ui.gd
extends Control
@onready var ready_texture_button = $ReadyTextureButton
@onready var countdown_30_seconds_label = $Countdown30SecondsLabel

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _on_options_texture_button_pressed():
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")
