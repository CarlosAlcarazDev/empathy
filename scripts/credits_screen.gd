extends Control

@onready var animation_player = $VBoxContainer/AnimationPlayer
@onready var audio_stream_player = $AudioStreamPlayer


func _ready():
	animation_player.play("credits_scroll")

	

func _on_animation_player_animation_finished(anim_name):
	
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")
	
func _unhandled_input(event):
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_ESCAPE:
			get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")
