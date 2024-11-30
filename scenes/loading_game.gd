extends Control

@onready var back_ground_texture_rect = $BackGroundTextureRect
@onready var loading_label = $LoadingLabel
@onready var loading_texture_progress_bar = $LoadingTextureProgressBar
@onready var loading_animation_player = $LoadingAnimationPlayer
@onready var go_audio_stream_player = $GoAudioStreamPlayer



func _ready():
		
	var volume_db = lerp(-80, 0, GameConfig.music_volume / 100.0)
	volume_db = lerp(-80, 0, GameConfig.sfx_volume / 100.0)
	go_audio_stream_player.volume_db = volume_db
	
	# Inicia la animación de progreso
	loading_animation_player.play("loading", 0, 1.3)
	
	# Cambia automáticamente a la próxima escena cuando la animación termina
	loading_animation_player.connect("animation_finished", Callable(self, "_on_animation_finished"))
	
func _on_animation_finished(anim_name: String):
	if anim_name == "loading":
		# Muestra el mensaje "Prepárate"
		loading_label.text = "Prepárate"
		loading_label.visible = true
		go_audio_stream_player.play()
		
		# Espera 1 segundo antes de cambiar la escena
		await get_tree().create_timer(2.0).timeout
		
		# Cambia a la escena principal del juego
		get_tree().change_scene_to_file("res://scenes/NewGame.tscn")
