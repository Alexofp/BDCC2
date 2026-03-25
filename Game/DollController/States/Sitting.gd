extends DollControllerState

func canSit() -> bool:
	return false

func onStart(_doll:DollController, _args:Array, _oldState:int):
	_doll.velocity = Vector3.ZERO
	_doll.knockbackVelocity = Vector3.ZERO

func canJump(_doll:DollController) -> bool:
	return false

func processCameraPivotPosition(_doll:DollController, _dt:float):
	var CameraPivot := _doll.CameraPivot
	var SpringArm := _doll.SpringArm
	
	SpringArm.position.x = 0.0
	CameraPivot.global_position = _doll.getBodySkeleton().getChestBoneAttachment().global_position + Vector3(0.0, 0.3, 0.0)

func isControllingLookDir() -> bool:
	return true
