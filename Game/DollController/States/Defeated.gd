extends DollControllerState

func canSit() -> bool:
	return false

func canJump(_doll:DollController) -> bool:
	return false

func canMove(_doll:DollController) -> bool:
	return false

func canDoCombatMoves() -> bool:
	return false

func shouldShowCombatUI() -> bool:
	return true

func canRun(_doll:DollController) -> bool:
	return false

func processCameraPivotPosition(_doll:DollController, _dt:float):
	var CameraPivot := _doll.CameraPivot
	var SpringArm := _doll.SpringArm
	
	SpringArm.position.x = 0.0
	CameraPivot.global_position = _doll.getBodySkeleton().getChestBoneAttachment().global_position + Vector3(0.0, 0.3, 0.0)

func processAnimation(_doll:DollController, _dt:float):
	#var isOnFloor := _doll.is_on_floor()
	var theDoll := _doll.getDoll()
	
	theDoll.animIdle("CollapseIdle")
	
	rotateTowardsMoveDirection(_doll, _dt)
	
func processMove(_doll:DollController, _dt:float):
	#var theCanMove := canMove(_doll)
	_doll.isRunning = false
	processGravity(_doll, _dt)
	_doll.velocity.x = _doll.velocity.x * 0.5
	_doll.velocity.z = _doll.velocity.z * 0.5
	
func processGravity(_doll:DollController, _dt:float):
	if(!_doll.noclip_on && !_doll.is_on_floor()):
		_doll.velocity.y -= DollController.GRAVITY_FORCE * _dt
