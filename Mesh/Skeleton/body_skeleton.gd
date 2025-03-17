extends Node3D
class_name BodySkeleton

@onready var vagina_hole: DollOpenableHole = %VaginaHole
@onready var vagina_inside: Marker3D = %VaginaInside

@onready var anus_hole: DollOpenableHole = %AnusHole
@onready var anus_inside: Marker3D = %AnusInside


func getVaginaHoleNode() -> DollOpenableHole:
	return vagina_hole

func getVaginaInsideNode() -> Node3D:
	return vagina_inside

func getAnusHoleNode() -> DollOpenableHole:
	return anus_hole

func getAnusInsideNode() -> Node3D:
	return anus_inside
