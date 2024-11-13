# CardsRE.gd
extends Resource
class_name CardsBU

@export var id_carta: int
@export var nombre: String
@export var descripcion: String
@export var tipo: String
@export var empatia: int
@export var apoyo_emocional: int
@export var intervencion: int
@export var comunicacion: int
@export var resolucion_de_conflictos: int

# Constructor para inicializar más fácilmente
func _init(_id_carta: int, _nombre: String, _descripcion: String, _tipo: String, _empatia: int, _apoyo_emocional: int, _intervencion: int, _comunicacion: int, _resolucion_de_conflictos: int):
	self.id_carta = _id_carta
	self.nombre = _nombre
	self.descripcion = _descripcion
	self.tipo = _tipo
	self.empatia = _empatia
	self.apoyo_emocional = _apoyo_emocional
	self.intervencion = _intervencion
	self.comunicacion = _comunicacion
	self.resolucion_de_conflictos = _resolucion_de_conflictos
