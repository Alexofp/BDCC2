extends DollControllerState

func canSit() -> bool:
	return false

func processCameraPivotPosition(_doll:DollController, _dt:float):
	var CameraPivot := _doll.CameraPivot
	var SpringArm := _doll.SpringArm
	
	SpringArm.position.x = 0.0
	CameraPivot.global_position = _doll.getBodySkeleton().getChestBoneAttachment().global_position + Vector3(0.0, 0.3, 0.0)
