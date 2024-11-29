# ===============================
# Nombre del Script: new_game.gd
# Desarrollador: Carlos Alcaraz Benítez
# Fecha de Creación: 06 de Noviembre de 2024
# Descripción: 
# ===============================
extends Control

@onready var reverse_anverse_toggle_button = $UI/ReverseAnverseToggleButton
@onready var audio_stream_player = $UI/AudioStreamPlayer
@onready var beep_audio_stream_player = $UI/BeepAudioStreamPlayer
@onready var beep_countdown_audio_stream_player = $UI/BeepCountdownAudioStreamPlayer
@onready var audio_stream_token = $UI/AudioStreamToken

# Controlador de canciones
var current_song_index = -1
var song_list = [
		"res://assets/audio/music/epic_orchestral_1.mp3", 
		"res://assets/audio/music/epic_orchestral_2.mp3", 
		"res://assets/audio/music/epic_orchestral_3.mp3", 
		"res://assets/audio/music/epic_orchestral_4.mp3",
		"res://assets/audio/music/epic_orchestral_5.mp3",
		"res://assets/audio/music/epic_orchestral_6.mp3"
]


# Called when the node enters the scene tree for the first time.
func _ready():
	# Reinicia combos y scores
	GlobalData.combo_ia = 0
	GlobalData.combo_player = 0
	GlobalData.hs_multiplier = 0
	GlobalData.re_multiplier = 0
	GlobalData.re_total_score = 0
	GlobalData.hs_total_score = 0
	GlobalData.total_ia_score = 0
	GlobalData.total_player_score = 0
	GlobalData.game_over_time_or_bu = false
	GlobalData.game_over_abort = false
	GlobalData.token_earned_ia["verbal"] = 0
	GlobalData.token_earned_ia["exclusión_social"] = 0
	GlobalData.token_earned_ia["psicológico"] = 0
	GlobalData.token_earned_ia["físico"] = 0
	GlobalData.token_earned_ia["sexual"] = 0
	GlobalData.token_earned_ia["ciberbullying"] = 0
	GlobalData.token_earned_player["verbal"] = 0
	GlobalData.token_earned_player["exclusión_social"] = 0
	GlobalData.token_earned_player["psicológico"] = 0
	GlobalData.token_earned_player["físico"] = 0
	GlobalData.token_earned_player["sexual"] = 0
	GlobalData.token_earned_player["ciberbullying"] = 0
	GlobalData.token_combos_ia["verbal"] = 0
	GlobalData.token_combos_ia["exclusión_social"] = 0
	GlobalData.token_combos_ia["psicológico"] = 0
	GlobalData.token_combos_ia["físico"] = 0
	GlobalData.token_combos_ia["sexual"] = 0
	GlobalData.token_combos_ia["ciberbullying"] = 0
	GlobalData.token_combos_player["verbal"] = 0
	GlobalData.token_combos_player["exclusión_social"] = 0
	GlobalData.token_combos_player["psicológico"] = 0
	GlobalData.token_combos_player["físico"] = 0
	GlobalData.token_combos_player["sexual"] = 0
	GlobalData.token_combos_player["ciberbullying"] = 0
	

	print("comb1: GlobalData.token_combos_player", GlobalData.token_combos_player)
	print("comb1: GlobalData.token_earned_player", GlobalData.token_earned_player)
	print("comb1: GlobalData.token_combos_ia", GlobalData.token_combos_ia)
	print("comb1: GlobalData.token_earned_ia", GlobalData.token_earned_ia)



	audio_stream_player.connect("finished", Callable(self, "_on_audio_stream_player_finished"))

	
	var volume_db = lerp(-80, 0, GameConfig.music_volume / 100.0)
	audio_stream_player.volume_db = volume_db
	volume_db = lerp(-80, 0, GameConfig.sfx_volume / 100.0)
	beep_audio_stream_player.volume_db = volume_db
	beep_countdown_audio_stream_player.volume_db = volume_db
	audio_stream_token.volume_db = volume_db
	start_playlist()
func start_playlist():
	# Baraja la lista de canciones para reproducirlas aleatoriamente
	song_list.shuffle()
	play_next_song()

func play_next_song():
	print("repro Cambiando a la siguiente canción...")
	current_song_index += 1
	if current_song_index >= song_list.size():
		current_song_index = 0  # Reinicia la lista si llegamos al final
		song_list.shuffle()
	var song_path = song_list[current_song_index]
	print("repro Cargando canción:", song_path)
	var song = load(song_path) as AudioStream
	if song:
		audio_stream_player.stream = song
		audio_stream_player.play()
		print("repro Reproduciendo:", song_path)

func _on_audio_stream_player_finished():
	# Cuando termine la canción, pasa a la siguiente
	print("repro cancion ha llegado a su fin")
	play_next_song()
