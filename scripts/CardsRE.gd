# ===============================
# Nombre del Script: CardsRE.gd
# Desarrollador: Carlos Alcaraz Benítez
# Fecha de Creación: 09 de Noviembre de 2024
# Descripción: Este script define la clase llamada CardsRE que representa las cartas de RESPUESTA EMPÁTICA
# ===============================
# 
extends Resource
# Define el nombre de la clase 
class_name CardsRE
#Propiedades exportadas
@export var id_carta: int
@export var nombre: String
@export var descripcion: String
@export var empatia: int
@export var apoyo_emocional: int
@export var intervencion: int
@export var contexto_en_el_juego: String
@export var afinidad: Dictionary


# Constructor para inicializar la clase con valores específicos
func _init(_id_carta: int, _nombre: String, _descripcion: String, _empatia: int, _apoyo_emocional: int, _intervencion: int, _contexto_en_el_juego: String, _afinidad: Dictionary):
	self.id_carta = _id_carta
	self.nombre = _nombre
	self.descripcion = _descripcion
	self.empatia = _empatia
	self.apoyo_emocional = _apoyo_emocional
	self.intervencion = _intervencion
	self.contexto_en_el_juego = _contexto_en_el_juego
	self.afinidad = _afinidad
