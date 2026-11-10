extends "res://Game/DollController/States/Sitting.gd"

func isStandingOrCanGetUpEasily() -> bool:
	return false

# Vec3(head, neck, chest)
func getTargetVecForLookAtModifiers(_doll:DollController) -> Vector3:
	return Vector3(0.0, 0.0, 0.0)

func processAnimation(_doll:DollController, _dt:float):
	_doll.getDoll().playLocomotionType(Doll.LOC_NORMAL)
