extends "res://Game/DollController/States/Normal.gd"

var attacking:float = 0.0

var walkAnim:Vector2
func processAnimation(_doll:DollController, _dt:float):
	var isOnFloor := _doll.is_on_floor()
	var theDoll := _doll.getDoll()
	var localVelocity := getLocalVelocity(_doll)
	var localWalkVec:Vector2 = limitVec2(Vector2(localVelocity.x, localVelocity.z)/calcWalkMoveSpeed(_doll), 1.0)
	#print(localWalkVec)
	
	var isOnFloorVisually:bool = isOnFloor
	
	if(_doll.doll_controls.attack_isDown && attacking <= 0.2):
		theDoll.animAttack()
		attacking = 0.9
	
	if(attacking > 0.0):
		attacking -= _dt
	else:
		if(!isOnFloorVisually):
			theDoll.animFall()
		elif _doll.velocity.length_squared() > 0.1: # A little buggy when you're pushing a prop
			if _doll.isRunning:
				theDoll.animRun()
			else:
				walkAnim = localWalkVec - (localWalkVec - walkAnim)*0.9
				theDoll.animCombat(walkAnim)
		else:
			walkAnim *= 0.9
			theDoll.animCombat(walkAnim)
	
	if(_doll.isRunning && attacking <= 0.0):
		rotateTowardsMoveDirection(_doll, _dt)
	else:
		rotateTowardsCamera(_doll, _dt)
	#print(getLocalVelocity(_doll))
	
func canMove(_doll:DollController) -> bool:
	if(attacking > 0.0):
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
