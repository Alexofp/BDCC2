extends Node
class_name DollControllerState

var pawn:CharacterPawn

func _ready() -> void:
	pawn = get_parent()

func onStart(_doll:DollController, _args:Array, _oldState:int):
	pass

func onStartOnlyPawn(_args:Array, _oldPawnState:int):
	pass

func canSit() -> bool:
	return true

func getDoll() -> DollController:
	return pawn.getDoll()

func processAnimation(_doll:DollController, _dt:float):
	_doll.getDoll().animStand()

func processSpecialInputs(_doll:DollController, _dt:float):
	pass

func processPhysics(_doll:DollController, _delta:float):
	processSpecialInputs(_doll, _delta)
	processMove(_doll, _delta)

func processDollLessPawn(_dt:float):
	pass

func processTick(_doll:DollController, _delta:float):
	#var theIsControlledByUs:bool = _doll.isControlledByUs()
	
	#if(theIsControlledByUs):
	processCamera(_doll, _delta)
	processAnimation(_doll, _delta)

func processMove(_doll:DollController, _delta:float):
	_doll.knockbackVelocity = Vector3.ZERO

# This code is probably framerate-dependant. I dunno how to fix it though
func processKnockbackVelocity(_doll:DollController, _delta:float):
	var theFriction:float = 0.1
	if(_doll.is_on_floor()):
		theFriction = 0.2
		if(_doll.knockbackVelocity.y < 0.0):
			_doll.knockbackVelocity.y *= 0.0
	if(_doll.is_on_ceiling()):
		if(_doll.knockbackVelocity.y > 0.0):
			_doll.knockbackVelocity.y = 0.0
	
	var f := clampf(theFriction, 0.0, 1.0)
	_doll.knockbackVelocity.x = lerp(_doll.knockbackVelocity.x, 0.0, f)
	_doll.knockbackVelocity.z = lerp(_doll.knockbackVelocity.z, 0.0, f)
	_doll.knockbackVelocity.y = lerp(_doll.knockbackVelocity.y, 0.0, 0.3)
	
	if(_doll.knockbackVelocity.length_squared() < 0.5):
		_doll.knockbackVelocity = Vector3.ZERO
	
	_doll.velocity += _doll.knockbackVelocity

func doJump(_doll:DollController):
	pass

func setTargetLookDir(_doll:DollController, _dir:Vector3):
	#if(!isControllingLookDir()):
	#	return
	_doll.targetLookDir = _dir

func setTargetLookDirFromMovement(_doll:DollController):
	#_doll.targetLookDir = Vector3(1.0, 0.0, 1.0)
	if _doll.move_direction_no_y.length_squared() > 0.1 && !_doll.isRemote():
		_doll.targetLookDir = _doll.move_direction_no_y
		#if(_doll.isControlledByPlayer()):
		#	print(_doll.move_direction_no_y)

func setTargetLookDirFromCamera(_doll:DollController):
	#if(!isControllingLookDir()):
	#	return
	#_doll.targetLookDir = -_doll.camera_rotation_no_y.get_euler()
	#_doll.targetLookDir = Basis(_doll.camera_rotation_no_y).rotated(Vector3.UP, PI).get_euler()
	#if(_doll.isControlledByPlayer()):
	#	print(_doll.camera_rotation_no_y.get_euler())
	_doll.targetLookDir = _doll.camera_rotation_no_y * Vector3.FORWARD#-_doll.camera_rotation_no_y.

func getRotationToTargetSpeed(_doll:DollController) -> float:
	return 1.0

func isControllingLookDir() -> bool:
	return false # If true, the "Face" ai action won't try to override the target look dir

func rotate_toward(from: Quaternion, to: Quaternion, delta: float) -> Quaternion:
	return from.slerp(to, clamp(delta / from.angle_to(to), 0.0, 1.0)).normalized()

func basis_rotate_toward(from: Basis, to: Basis, delta: float) -> Basis:
	return from.slerp(to, delta)
	#return Basis(rotate_toward(from.get_rotation_quaternion(), to.get_rotation_quaternion(), delta)).orthonormalized()

func rotateTowardsMoveDirection(_doll:DollController, _dt:float):
	if(Network.isClient()):
		return
	if _doll.move_direction_no_y.length_squared() > 0.1 && !_doll.isRemote():
		_doll.model_root.basis = basis_rotate_toward(_doll.model_root.basis, Basis.looking_at(-_doll.move_direction_no_y), _doll.ROTATE_SPEED * _dt)

func rotateTowardsDirection(_doll:DollController, _dt:float, _dir:Vector3):
	if(Network.isClient()):
		return
	_dir.y = 0.0
	_dir = _dir.normalized()
	if _dir.length_squared() > 0.1 && !_doll.isRemote():
		_doll.model_root.basis = basis_rotate_toward(_doll.model_root.basis, Basis.looking_at(-_dir), _doll.ROTATE_SPEED * _dt)

func rotateTowardsPos(_doll:DollController, _dt:float, _pos:Vector3):
	if(Network.isClient()):
		return
	var _dir:Vector3 = _pos - _doll.global_position
	_dir.y = 0.0
	_dir = _dir.normalized()
	if _dir.length_squared() > 0.1 && !_doll.isRemote():
		_doll.model_root.basis = basis_rotate_toward(_doll.model_root.basis, Basis.looking_at(-_dir), _doll.ROTATE_SPEED * _dt)

func rotateTowardsCamera(_doll:DollController, _dt:float):
	if(Network.isClient()):
		return
	_doll.model_root.basis = basis_rotate_toward(_doll.model_root.basis, Basis(_doll.camera_rotation_no_y).rotated(Vector3.UP, PI), _doll.ROTATE_SPEED * _dt)

func getLocalVelocity(_doll:DollController) -> Vector3:
	return _doll.getLocalVelocity()

func calcWalkMoveSpeed(_doll:DollController) -> float:
	return DollController.ANIM_MOVE_SPEED * DollController.MOVE_MULT * _doll.getWalkSpeedMult()

func calcRunMoveSpeed(_doll:DollController) -> float:
	return DollController.ANIM_RUN_SPEED * DollController.RUN_MULT

func limitVec2(_vec2:Vector2, _maxSpeed:float) -> Vector2:
	var theLen := _vec2.length()
	if(theLen <= _maxSpeed):
		return _vec2
	return _vec2 / theLen * _maxSpeed

func limitVec3(_vec3:Vector3, _maxSpeed:float) -> Vector3:
	var theLen := _vec3.length()
	if(theLen <= _maxSpeed):
		return _vec3
	return _vec3 / theLen * _maxSpeed

func processCamera(_doll:DollController, _dt:float):
	var doll_controls := _doll.doll_controls
	var SpringArm := _doll.SpringArm
	var CameraPivot := _doll.CameraPivot
	
	if(!_doll.camera.isActive()):
		if(Network.isServer() && _doll.isControlledByAnyPlayer() && !_doll.isControlledByUs()):
			_doll.camera_rotation = doll_controls.sync_camera
			CameraPivot.basis = Basis(_doll.camera_rotation)
			_doll.camera_rotation_no_y = Basis(CameraPivot.basis.x, Vector3.UP, CameraPivot.basis.z).get_rotation_quaternion()
			#Log.Print("Meow")
		return

	
	if(Network.isServer() && _doll.isControlledByAnyPlayer() && !_doll.isControlledByUs()):
		#_doll.camera_rotation = doll_controls.sync_camera
		#CameraPivot.basis = Basis(_doll.camera_rotation)
		#_doll.camera_rotation_no_y = Basis(CameraPivot.basis.x, Vector3.UP, CameraPivot.basis.z).get_rotation_quaternion()
	#elif(_doll.isControlledByUs()):
		pass
	#else:
	
	var shouldDoLocalCamera:bool = false
	if(Network.isServer()):
		if(!_doll.isControlledByAnyPlayer() || _doll.isControlledByUs()):
			shouldDoLocalCamera = true
	if(Network.isClient()):
		if(_doll.isControlledByUs()):
			shouldDoLocalCamera = true
	
	if(shouldDoLocalCamera):
		var camera_rotation_euler := _doll.camera_rotation.get_euler()
		camera_rotation_euler += Vector3(doll_controls.camera_dir.y, doll_controls.camera_dir.x, 0.0) * _doll.LOOK_SENSITIVITY_TOUCH * (-1.0 if _doll.getDoll().isFirstPerson() else 1.0)
		if _doll.mousecapture_on:
			camera_rotation_euler += Vector3(doll_controls.mouse_movement.y, doll_controls.mouse_movement.x, 0) * _doll.LOOK_SENSITIVITY
		camera_rotation_euler.x = clamp(camera_rotation_euler.x, _doll.LOOK_LIMIT_LOWER, _doll.LOOK_LIMIT_UPPER)
		
		_doll.camera_rotation = Quaternion.from_euler(camera_rotation_euler)
		CameraPivot.basis = Basis(_doll.camera_rotation)
		_doll.camera_rotation_no_y = Basis(CameraPivot.basis.x, Vector3.UP, CameraPivot.basis.z).get_rotation_quaternion()
		
		if(Network.isClient()):
			doll_controls.sync_camera = _doll.camera_rotation
			#Log.Print(str(doll_controls.sync_camera))
		
	doll_controls.mouse_movement = Vector2.ZERO

	if(!UIHandler.hasAnyUIVisible()):
		if(Input.is_action_just_pressed("camera_zoomin") && _doll.canScrollDown()):
			SpringArm.spring_length -= 0.1
		if(Input.is_action_just_pressed("camera_zoomout") && _doll.canScrollUp()):
			SpringArm.spring_length += 0.1

	processCameraPivotPosition(_doll, _dt)

func processCameraPivotPosition(_doll:DollController, _dt:float):
	var SpringArm := _doll.SpringArm
	var CameraPivot := _doll.CameraPivot
	
	if(!_doll.processDollPoseCamera()):
		if(SpringArm.spring_length <= 0.0):
			SpringArm.spring_length = 0.0
			SpringArm.position.x = 0.0
		elif(SpringArm.spring_length <= 1.0):
			SpringArm.position.x = 0.1
			CameraPivot.position.y = 1.525
		else:
			SpringArm.position.x = 0.3
			CameraPivot.position.y = 1.125

	CameraPivot.position.x = 0
	CameraPivot.position.z = 0

func canMove(_doll:DollController) -> bool:
	return true

func canDoCombatMoves() -> bool:
	return false

func processHit(_attackContext:AttackContext) -> int:
	var hitStatus:int = AttackEffects.STATUS_HIT
	#var theAttack := _attackContext.attack
	#var theDamageMult:float = theAttack.damage
	if(isBlocking() && CombatMovePlayer.isInCone(_attackContext.target, _attackContext.attacker, 90.0)):
		_attackContext.blocked = true
		hitStatus = AttackEffects.STATUS_BLOCKED
	
	var theCharacter := pawn.getCharacter()
	if(theCharacter):
		theCharacter.processHit(_attackContext)
	
	var theDoll := getDoll()
	if(theDoll):
		onDollHit(theDoll, _attackContext)
	
	if(Network.isServer()):
		GM.actionSystem.onPawnHit(pawn, _attackContext)
		
		if(theCharacter.charState.getPainLevel() >= 1.0 && canBeDefeated()):
			pawn.makeDefeatedFromAttack(_attackContext)

		
		pawn.combatMovePlayer.onHit(_attackContext)
		pawn.combatAI.onHit(_attackContext)
		
		pawn.ai.onGettingHit(_attackContext)
		
		if(!_attackContext.blocked):
			pawn.interruptSay()
	return hitStatus

func canBeDefeated() -> bool:
	return false

func canCollapse() -> bool:
	return canBeDefeated()

func calculateCombatVulnerability() -> float:
	if(pawn.isBlocking()):
		return -1.0 + pawn.combatMovePlayer.getExhaustionLevel()
	return 0.0 + pawn.combatMovePlayer.getExhaustionLevel()

func onDollHit(_doll:DollController, _attackContext:AttackContext):
	#_doll.applyHitRandom(2.0)
	var theDir:Vector3 = _attackContext.attacker.getGlobalPos() - _attackContext.target.getGlobalPos()
	
	var theAttack:AttackInfo = _attackContext.attack
	
	#var theRecoil:float = sqrt(theAttack.damage*1.0)*3.0 if theAttack.damage > 0.0 else 0.0
	#if(_attackContext.blocked):
	#	theRecoil *= 0.4
	#_doll.getDoll().applyHitSpecific(theRecoil, theDir, true, Doll.HIT_AREA_MIDDLE)
	
	var theKnockback:float = theAttack.knockback if !_attackContext.blocked else theAttack.knockbackBlocked
	if(abs(theKnockback)>0.01):
		_doll.addKnockback(-theDir.normalized()*theKnockback*2.0)

func shouldShowCombatUI() -> bool:
	return false

func isTryingToBlock() -> bool:
	return false

func isBlocking() -> bool:
	if(!pawn.combatMovePlayer.isTryingToBlock()):
		return false
	var theDoll := getDoll()
	if(theDoll && theDoll.isRunning):
		return false
	
	return true

func canJump(_doll:DollController) -> bool:
	return _doll.is_on_floor() && !_doll.noclip_on

func canDoCouplesAnims() -> bool:
	return false

func isStandingOrCanGetUpEasily() -> bool:
	return canDoCouplesAnims()

# Vec3(head, neck, chest)
func getTargetVecForLookAtModifiers(_doll:DollController) -> Vector3:
	return Vector3(1.0, 1.0, 1.0)

func processDollLookAtModifiers(_doll:DollController, _dt:float):
	var theVec := getTargetVecForLookAtModifiers(_doll)
	var theDoll := _doll.getDoll()
	theDoll.lookModHead = Util.moveValueTo(theDoll.lookModHead, theVec.x, _dt)
	theDoll.lookModNeck = Util.moveValueTo(theDoll.lookModNeck, theVec.y, _dt)
	theDoll.lookModChest = Util.moveValueTo(theDoll.lookModChest, theVec.z, _dt)
