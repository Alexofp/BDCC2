extends "res://Mesh/Parts/Body/FeminineBody/feminine_body.gd"

func getShouldersWidth() -> float:
	return 1.0

func calcBreastPhysics(_breasts:float):
	if(_breasts < 1.1):
		breastWigglePhysics = clamp( remap(_breasts, 0.0, 1.1, 0.0, 0.1) , 0.1, 1.0)
	else:
		breastWigglePhysics = clamp( remap(_breasts, 1.1, 2.0, 0.1, 1.0) , 0.1, 1.0)
