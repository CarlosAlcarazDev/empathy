extends RichTextLabel

@export var rich_text_label: RichTextLabel


func _ready():
	# Activar el uso de BBCode en el RichTextLabel
	rich_text_label.bbcode_enabled = true
	
	# Establecer el texto utilizando BBCode
	rich_text_label.bbcode_text = "[size=32][b][color=#00FF00]Camino a Casa[/color][/b][/size]"
