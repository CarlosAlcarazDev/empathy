# ===============================
# Nombre del Script: CardsBu.gd
# Desarrollador: Carlos Alcaraz Benítez
# Fecha de Creación: 09 de Noviembre de 2024
# Descripción: Este script define la clase llamada CardsBU que representa las cartas de Bullying
# ===============================
# 
extends Resource
# Define el nombre de la clase 
class_name CardsBU
#Propiedades exportadas
@export var id_carta: int
@export var nombre: String
@export var descripcion: String
@export var tipo: String
@export var empatia: int
@export var apoyo_emocional: int
@export var intervencion: int
@export var comunicacion: int
@export var resolucion_de_conflictos: int

# Constructor para inicializar la clase con valores específicos
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
