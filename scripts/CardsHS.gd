# ===============================
# Nombre del Script: CardsHS.gd
# Desarrollador: Carlos Alcaraz Benítez
# Fecha de Creación: 09 de Noviembre de 2024
# Descripción: Este script define la clase llamada CardsHS que representa las cartas de HABILIDAD SOCIAL
# ===============================
# 
extends Resource
# Define el nombre de la clase 
class_name CardsHS
#Propiedades exportadas
@export var id_carta: int
@export var nombre: String
@export var descripcion: String
@export var comunicacion: int
@export var resolucion_de_conflictos: int
@export var contexto_en_el_juego: String
@export var afinidad: Dictionary


# Constructor para inicializar la clase con valores específicos
func _init(_id_carta: int, _nombre: String, _comunicacion: int, _resolucion_de_conflictos: int, _descripcion: String, _contexto_en_el_juego: String, _afinidad: Dictionary):
	self.id_carta = _id_carta
	self.nombre = _nombre
	self.comunicacion = _comunicacion
	self.resolucion_de_conflictos = _resolucion_de_conflictos
	self.descripcion = _descripcion
	self.contexto_en_el_juego = _contexto_en_el_juego
	self.afinidad = _afinidad
