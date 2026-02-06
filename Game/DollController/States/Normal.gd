extends DollControllerState

func processAnimation(_doll:DollController, _dt:float):
	var isOnFloor := _doll.is_on_floor()
	#if(isOnFloor):
		#rememberFloorTimer = 0.1
	#elif(rememberFloorTimer > 0.0):
		#rememberFloorTimer -= _delta
	
	var isOnFloorVisually:bool = isOnFloor#(rememberFloorTimer > 0.0)
	
	if(!isOnFloorVisually):
		_doll.getDoll().animFall()
	elif _doll.velocity.length_squared() > 0.1: # A little buggy when you're pushing a prop
		if _doll.isRunning:
			_doll.getDoll().animRun()
		else:
			_doll.getDoll().animWalk()
		#Log.Print(str(move_direction))
	else:
		_doll.getDoll().animStand()
	
	if _doll.move_direction_no_y != Vector3.ZERO && !_doll.isRemote():
		_doll.model_root.basis = basis_rotate_toward(_doll.model_root.basis, Basis.looking_at(-_doll.move_direction_no_y), _doll.ROTATE_SPEED * _dt)

func processMove(_doll:DollController, delta:float):
	var yankHasPower:bool = _doll.yankWalkDir.length_squared() > 0.01
	
	if(yankHasPower && !_doll.noclip_on && _doll.doll_controls.move_direction.length_squared()<0.01):
		_doll.move_direction = _doll.yankWalkDir.normalized()
		_doll.move_direction_no_y = Vector3(_doll.move_direction.x, 0.0, _doll.move_direction.z).normalized()

	else:
		_doll.move_direction = _doll.doll_controls.move_direction
		_doll.move_direction_no_y = _doll.doll_controls.move_direction_no_y

	if(Network.isServer() && yankHasPower): #Server's job to do this
		_doll.yankWalkDir *= 0.8
	#YANK END
	
	
	_doll.isRunning = false
	if(_doll.doll_controls.sprint_isdown || _doll.yankWalkDir.length_squared()>9.0) && _doll.canSprint():
		_doll.isRunning = true
	if(!_doll.isRemote()):
		var move_speed: = DollController.ANIM_MOVE_SPEED * DollController.MOVE_MULT * _doll.getWalkSpeedMult()
		if(_doll.isRunning):
			move_speed = DollController.ANIM_RUN_SPEED * DollController.RUN_MULT
			if(_doll.noclip_on):
				move_speed *= DollController.NOCLIP_MULT
		
		if _doll.noclip_on:
			_doll.velocity = _doll.move_direction * move_speed
		else:
			#var isOnFloor = is_on_floor()
			
			_doll.velocity.x = _doll.move_direction_no_y.x * move_speed 
			_doll.velocity.z = _doll.move_direction_no_y.z * move_speed
			
			# Uncomment for root motion
			#if(isOnFloor):
				#var current_dir_no_y = model_root.basis * Vector3.BACK
				#
				#var rootPos = getBodySkeleton().getRootPos()
				#velocity.x = current_dir_no_y.x * rootPos.z / delta * 2.0
				#velocity.z = current_dir_no_y.z * rootPos.z / delta * 2.0
			#else:
				## In air
				#velocity.x = move_direction_no_y.x * move_speed 
				#velocity.z = move_direction_no_y.z * move_speed
			if _doll.doll_controls.jump_isdown && _doll.is_on_floor() && !_doll.noclip_on:
				_doll.doJump()
				#yankWalkDir = Vector3(10.0, 0.0, 0.0)
				#applyHitRandom(10.0) #Funny
				#addHoverText("JUMP!")
	
	if !_doll.noclip_on:
		if not _doll.is_on_floor():
			_doll.velocity.y -= DollController.GRAVITY_FORCE * delta
