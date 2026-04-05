extends DollControllerState

func canMove(_doll:DollController) -> bool:
	#if(attacking > 0.0):
	#	return false
	if(!pawn.combatMovePlayer.canMove()):
		return false
	return true

func doJump(_doll:DollController):
	if(!_doll.is_on_floor() || _doll.noclip_on):
		return
	_doll.velocity.y = _doll.JUMP_FORCE * _doll.getJumpHeight()

func isControllingLookDir() -> bool:
	var theDoll := pawn.getDoll()
	if(theDoll && theDoll.velocity.length_squared() > 0.1):
		return true
	return false

#var walkAnim:float = 0.0
func processAnimation(_doll:DollController, _dt:float):
	#var isOnFloor := _doll.is_on_floor()
	var theDoll := _doll.getDoll()
	#if(isOnFloor):
		#rememberFloorTimer = 0.1
	#elif(rememberFloorTimer > 0.0):
		#rememberFloorTimer -= _delta
	
	#var isOnFloorVisually:bool = isOnFloor#(rememberFloorTimer > 0.0)
	
	if(!_doll.isOnFloorVisually):
		theDoll.animFall()
	elif _doll.velocity.length_squared() > 0.1: # A little buggy when you're pushing a prop
		if _doll.isRunning:
			theDoll.animRun()
		else:
			#walkAnim = 1.0 - (1.0 - walkAnim)*0.9
			#theDoll.animCombat(Vector2(0.0, walkAnim))
			theDoll.animWalk()
		#Log.Print(str(move_direction))
	else:
		#walkAnim *= 0.9
		#theDoll.animCombat(Vector2(0.0, walkAnim))
		theDoll.animStand()
	
	#rotateTowardsMoveDirection(_doll, _dt)
	setTargetLookDirFromMovement(_doll)
	

func processYanking(_doll:DollController, _delta:float):
	var yankHasPower:bool = _doll.yankWalkDir.length_squared() > 0.01
	
	if(yankHasPower && !_doll.noclip_on && _doll.doll_controls.move_direction.length_squared()<0.01):
		_doll.move_direction = _doll.yankWalkDir.normalized()
		_doll.move_direction_no_y = Vector3(_doll.move_direction.x, 0.0, _doll.move_direction.z).normalized()
	else:
		_doll.move_direction = _doll.doll_controls.move_direction
		_doll.move_direction_no_y = _doll.doll_controls.move_direction_no_y

	if(Network.isServer() && yankHasPower): #Server's job to do this
		_doll.yankWalkDir *= 0.8


func canRun(_doll:DollController) -> bool:
	if(!_doll.canSprint()):
		return false
	return true

func processMove(_doll:DollController, _dt:float):
	if(Network.isServer() && _doll.doll_controls.combatMode_isDown):
		if(pawn.getState() == pawn.STATE_NORMAL):
			pawn.setState(pawn.STATE_COMBAT)
		else:
			pawn.setState(pawn.STATE_NORMAL)
	
	processYanking(_doll, _dt)
	var theCanMove := canMove(_doll)
	
	if(Network.isServer()):
		_doll.isRunning = false
		if(_doll.doll_controls.sprint_isdown || _doll.yankWalkDir.length_squared()>9.0) && canRun(_doll):
			_doll.isRunning = true
	
	
	if(!_doll.isRemote()):
		var move_speed: = calcWalkMoveSpeed(_doll)
		if(_doll.isRunning):
			move_speed = calcRunMoveSpeed(_doll)
			if(_doll.noclip_on):
				move_speed *= DollController.NOCLIP_MULT
		
		if(!theCanMove):
			move_speed = 0.0
		
		if _doll.noclip_on:
			_doll.velocity = _doll.move_direction * move_speed
		else:
			#var isOnFloor = is_on_floor()
			
			_doll.velocity.x = _doll.move_direction_no_y.x * move_speed 
			_doll.velocity.z = _doll.move_direction_no_y.z * move_speed
			
			var finalCombatVel := pawn.combatMovePlayer.getFinalVel()
			if(finalCombatVel.length_squared() > 0.01):
				_doll.velocity += _doll.getBodyRotationGlobalBasis().orthonormalized() * (finalCombatVel + Vector3(0.0, -0.1, 0.0))
			# Uncomment for root motion
			#if(isOnFloor):
				#var current_dir_no_y = model_root.basis * Vector3.BACK
				#
				#var rootPos = getBodySkeleton().getRootPos()
				#velocity.x = current_dir_no_y.x * rootPos.z / _dt * 2.0
				#velocity.z = current_dir_no_y.z * rootPos.z / _dt * 2.0
			#else:
				## In air
				#velocity.x = move_direction_no_y.x * move_speed 
				#velocity.z = move_direction_no_y.z * move_speed
			if _doll.doll_controls.jump_isdown:
				if(canJump(_doll)):
					_doll.doJump()
				#yankWalkDir = Vector3(10.0, 0.0, 0.0)
				#applyHitRandom(10.0) #Funny
				#addHoverText("JUMP!")
	
	processGravity(_doll, _dt)
	processKnockbackVelocity(_doll, _dt)
	
func processGravity(_doll:DollController, _dt:float):
	if(!_doll.noclip_on && !_doll.is_on_floor()):
		_doll.velocity.y -= DollController.GRAVITY_FORCE * _dt

func canBeDefeated() -> bool:
	return true

func canDoCouplesAnims() -> bool:
	return true

func isStandingOrCanGetUpEasily() -> bool:
	return true
