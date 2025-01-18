extends BodypartBodyBase

func _init():
	id = "FeminineBody"

func getName() -> String:
	return "Feminine body"

func getPackedScene() -> PackedScene:
	return preload("res://Mesh/Parts/Body/FeminineBody/feminine_body.tscn")
