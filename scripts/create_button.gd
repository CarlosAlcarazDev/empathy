extends Button

@onready var audio_stream_player = $AudioStreamPlayer

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.



func _on_pressed():
	audio_stream_player.playing = true
