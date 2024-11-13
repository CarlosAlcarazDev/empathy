# CardsRE.gd
extends Resource
class_name CardsRE

@export var id_carta: int
@export var nombre: String
@export var descripcion: String
@export var empatia: int
@export var apoyo_emocional: int
@export var intervencion: int

# Constructor para inicializar más fácilmente
func _init(_id_carta: int, _nombre: String, _descripcion: String, _empatia: int, _apoyo_emocional: int, _intervencion: int):
	self.id_carta = _id_carta
	self.nombre = _nombre
	self.descripcion = _descripcion
	self.empatia = _empatia
	self.apoyo_emocional = _apoyo_emocional
	self.intervencion = _intervencion
