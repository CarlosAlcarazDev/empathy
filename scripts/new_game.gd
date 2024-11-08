
extends Control
@onready var animation_player = $VBoxContainer/AnimationPlayer


# Called when the node enters the scene tree for the first time.
func _ready():
	animation_player.play("credits_scroll")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_volver_pressed():
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")
