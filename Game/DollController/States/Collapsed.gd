extends DollControllerState

var collapseMinTimer:float = 1.0

func onStart(_doll:DollController, _args:Array, _oldState:int):
	if(_oldState in [pawn.STATE_COMBAT, pawn.STATE_NORMAL, pawn.STATE_SITTING]):
		if(_doll && _doll.knockbackVelocity.y <= 1.0):
			pawn.doCombatAnim("CollapseFromCombat", true)
		else:
			pawn.doCombatAnim("CollapseFlyFromCombat", true)
	collapseMinTimer = 1.0
	
	onStartOnlyPawn(_args, _oldState)

func onStartOnlyPawn(_args:Array, _oldPawnState:int):
	pawn.combatMovePlayer.onCollapse()
	if(Network.isServer()):
		var allLeashes := GM.leashSystem.getAllLeashesOfSourceNode(pawn)
		for leash in allLeashes.duplicate():
			leash.queue_free()
	pass

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

func canBeDefeated() -> bool:
	return true

func processCameraPivotPosition(_doll:DollController, _dt:float):
	var CameraPivot := _doll.CameraPivot
	var SpringArm := _doll.SpringArm
	
	SpringArm.position.x = 0.0
	CameraPivot.global_position = _doll.getBodySkeleton().getChestBoneAttachment().global_position + Vector3(0.0, 0.3, 0.0)

func processAnimation(_doll:DollController, _dt:float):
	#var isOnFloor := _doll.is_on_floor()
	var theDoll := _doll.getDoll()
	
	if(_doll.gotOntoFloorThisFrame):
		_doll.gotOntoFloorThisFrame = false
		pawn.doCombatAnim("CollapseFlyingToFloor", true)
	
	if(_doll.isOnFloorVisually && _doll.knockbackVelocity.y <= 1.0):
		theDoll.animIdle("CollapseIdle")
	else:
		theDoll.animIdle("CollapseFlyingIdle")
	
	if(_doll.is_on_floor()):
		collapseMinTimer -= _dt
		if(collapseMinTimer <= 0.0):
			pawn.recoverFromCollapse()
			#pawn.doCombatAnim("CollapseToCombat", true)
			#pawn.setState(pawn.STATE_COMBAT)
			#pawn.combatMovePlayer.makeNoMove(0.8)
	if(_doll.isOnFloorVisually):
		setTargetLookDirFromMovement(_doll)
		#rotateTowardsMoveDirection(_doll, _dt*0.1)
	else:
		if(_doll.velocity.length_squared() > 0.1):
			var theDir := _doll.velocity.rotated(Vector3.UP, PI)
			#rotateTowardsDirection(_doll, _dt*3.0, theDir)
			setTargetLookDir(_doll, theDir)

func getRotationToTargetSpeed(_doll:DollController) -> float:
	if(_doll.isOnFloorVisually):
		return 0.1
	if(_doll.velocity.length_squared() > 0.1):
		return 3.0
	return 0.0

func processDollLessPawn(_dt:float):
	collapseMinTimer -= _dt
	if(collapseMinTimer <= 0.0):
		pawn.setState(pawn.STATE_COMBAT)

func processMove(_doll:DollController, _dt:float):
	#var theCanMove := canMove(_doll)
	_doll.isRunning = false
	processGravity(_doll, _dt)
	processYanking(_doll, _dt)
	processKnockbackVelocity(_doll, _dt)
	_doll.velocity.x = _doll.velocity.x * 0.5
	_doll.velocity.z = _doll.velocity.z * 0.5
	
	#rotateTowardsMoveDirection(_doll, _dt*0.0)
	
func processGravity(_doll:DollController, _dt:float):
	if(!_doll.noclip_on && !_doll.is_on_floor()):
		_doll.velocity.y -= DollController.GRAVITY_FORCE * _dt

func processYanking(_doll:DollController, _delta:float):
	var yankHasPower:bool = _doll.yankWalkDir.length_squared() > 0.01
	
	if(yankHasPower && !_doll.noclip_on && _doll.doll_controls.move_direction.length_squared()<0.01):
		_doll.move_direction = _doll.yankWalkDir.normalized()
		#_doll.move_direction.z += PI
		_doll.move_direction = _doll.move_direction.rotated(Vector3.UP, PI)
		_doll.move_direction_no_y = Vector3(_doll.move_direction.x, 0.0, _doll.move_direction.z).normalized()
	else:
		_doll.move_direction = _doll.doll_controls.move_direction
		_doll.move_direction_no_y = _doll.doll_controls.move_direction_no_y

	if(Network.isServer() && yankHasPower): #Server's job to do this
		_doll.yankWalkDir *= 0.8

func isStandingOrCanGetUpEasily() -> bool:
	return false
