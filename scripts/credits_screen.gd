extends Control

@onready var animation_player = $VBoxContainer/AnimationPlayer
@onready var audio_stream_player = $AudioStreamPlayer


func _ready():
	var volume_db = lerp(-80, 0, GameConfig.music_volume / 100.0)
	audio_stream_player.volume_db = volume_db
	print("velocidad: " +str(animation_player.get_playing_speed()))
	animation_player.play("credits_scroll", 0, 0.5)
	

	

func _on_animation_player_animation_finished():
	
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")
	
func _unhandled_input(event):
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_ESCAPE:
			get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")
