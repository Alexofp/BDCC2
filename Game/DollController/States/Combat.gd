extends "res://Game/DollController/States/Normal.gd"

#var attacking:float = 0.0
var tryingToBlock:bool = false

func processSpecialInputs(_doll:DollController, _dt:float):
	tryingToBlock = _doll.doll_controls.block_isDown # Move this to the doll controller maybe?
	if(Network.isServer() && !_doll.noclip_on):
		if(_doll.doll_controls.attack_isDown): # && attacking <= 0.2
			_doll.doll_controls.attack_isDown = false #hack
			#theDoll.animAttack()
			#attacking = 0.9
			if(pawn.combatMovePlayer.activateTrigger(CombatMoveBase.ACTIVATE_ATTACK1)):
				#theDoll.animAttack()
				pass
		#if(_doll.doll_controls.sprint_isdown):
		if(_doll.doll_controls.shift_isdown):
			_doll.doll_controls.shift_isdown = false #hack
			if(pawn.combatMovePlayer.activateTrigger(CombatMoveBase.ACTIVATE_SHIFT)):
				pass
		if(_doll.doll_controls.heavyAttack_isDown && !_doll.isRunning):
			_doll.doll_controls.heavyAttack_isDown = false #hack
			if(pawn.combatMovePlayer.activateTrigger(CombatMoveBase.ACTIVATE_SPACE)):
				pass
	#print(isBlocking())
	
var walkAnim:Vector2
func processAnimation(_doll:DollController, _dt:float):
	var isOnFloor := _doll.is_on_floor()
	var theDoll := _doll.getDoll()
	var localVelocity := getLocalVelocity(_doll)
	var localWalkVec:Vector2 = limitVec2(Vector2(localVelocity.x, localVelocity.z)/calcWalkMoveSpeed(_doll), 1.0)
	#print(localWalkVec)
	
	var areWeBlocking := isBlocking()
	
	var isOnFloorVisually:bool = isOnFloor
	
	#var isDoingAMove:bool = pawn.combatMovePlayer.isDoingAMove()
	
	#if(attacking > 0.0):
	#	attacking -= _dt
	if(false):#isDoingAMove):
		pass
	else:
		if(!isOnFloorVisually):
			theDoll.animFall()
		elif _doll.velocity.length_squared() > 0.1: # A little buggy when you're pushing a prop
			if _doll.isRunning:
				theDoll.animRun()
			else:
				walkAnim = localWalkVec - (localWalkVec - walkAnim)*0.9
				theDoll.animCombat(walkAnim, "combat" if !areWeBlocking else "block")
		else:
			walkAnim *= 0.9
			theDoll.animCombat(walkAnim, "combat" if !areWeBlocking else "block")
	
	if(_doll.isRunning || shouldFollowMoveDirection()): # && attacking <= 0.0
		rotateTowardsMoveDirection(_doll, _dt)
	else:
		rotateTowardsCamera(_doll, _dt)
	#print(getLocalVelocity(_doll))
	
func canMove(_doll:DollController) -> bool:
	#if(attacking > 0.0):
	#	return false
	if(!pawn.combatMovePlayer.canMove()):
		return false
	return true
	
func processCameraPivotPosition(_doll:DollController, _dt:float):
	var SpringArm := _doll.SpringArm
	var CameraPivot := _doll.CameraPivot
	
	if(!_doll.processDollPoseCamera()):
		if(SpringArm.spring_length <= 0.0):
			SpringArm.spring_length = 0.0
			#SpringArm.position.x = 0.0
		if(SpringArm.spring_length <= 1.0):
			SpringArm.position.x = 0.4
			CameraPivot.position.y = 1.425
		else:
			SpringArm.position.x = 0.6
			CameraPivot.position.y = 1.125

	CameraPivot.position.x = 0
	CameraPivot.position.z = 0

func canDoCombatMoves() -> bool:
	return true

func canRun(_doll:DollController) -> bool:
	if(pawn.combatMovePlayer.isDoingAMove()):
		return false
	if(pawn.combatMovePlayer.isMovingByAnAttack()):
		return false
	
	return true

func shouldShowCombatUI() -> bool:
	return true

func isTryingToBlock() -> bool:
	return tryingToBlock

func shouldFollowMoveDirection() -> bool:
	if(pawn.combatMovePlayer.shouldFollowMoveDirection()):
		return true
	return false

func canJump(_doll:DollController) -> bool:
	if(_doll.isRunning):
		return true
	return false

func doJump(_doll:DollController):
	if(_doll.isRunning):
		return super.doJump(_doll)
	return
