# CardsHS.gd
extends Resource
class_name CardsHS

@export var id_carta: int
@export var nombre: String
@export var descripcion: String
@export var comunicacion: int
@export var resolucion_de_conflictos: int


# Constructor para inicializar más fácilmente
func _init(_id_carta: int, _nombre: String, _comunicacion: int, _resolucion_de_conflictos: int, _descripcion: String):
	self.id_carta = _id_carta
	self.nombre = _nombre
	self.comunicacion = _comunicacion
	self.resolucion_de_conflictos = _resolucion_de_conflictos
	self.descripcion = _descripcion
