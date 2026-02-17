extends Node
class_name DollControllerState

var pawn:CharacterPawn

func _ready() -> void:
	pawn = get_parent()

func canSit() -> bool:
	return true

func getDoll() -> DollController:
	return pawn.getDoll()

func processAnimation(_doll:DollController, _dt:float):
	_doll.getDoll().animStand()

func processMove(_doll:DollController, _delta:float):
	pass

func doJump(_doll:DollController):
	pass

func rotate_toward(from: Quaternion, to: Quaternion, delta: float) -> Quaternion:
	return from.slerp(to, clamp(delta / from.angle_to(to), 0.0, 1.0)).normalized()

func basis_rotate_toward(from: Basis, to: Basis, delta: float) -> Basis:
	return from.slerp(to, delta)
	#return Basis(rotate_toward(from.get_rotation_quaternion(), to.get_rotation_quaternion(), delta)).orthonormalized()

func rotateTowardsMoveDirection(_doll:DollController, _dt:float):
	if _doll.move_direction_no_y.length_squared() > 0.1 && !_doll.isRemote():
		_doll.model_root.basis = basis_rotate_toward(_doll.model_root.basis, Basis.looking_at(-_doll.move_direction_no_y), _doll.ROTATE_SPEED * _dt)

func rotateTowardsCamera(_doll:DollController, _dt:float):
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
	if(!_doll.camera.isActive()):
		return
	var camera_rotation_euler := _doll.camera_rotation.get_euler()
	var doll_controls := _doll.doll_controls
	var SpringArm := _doll.SpringArm
	var CameraPivot := _doll.CameraPivot
	
	camera_rotation_euler += Vector3(doll_controls.camera_dir.y, doll_controls.camera_dir.x, 0.0) * _doll.LOOK_SENSITIVITY_TOUCH * (-1.0 if _doll.getDoll().isFirstPerson() else 1.0)
	if _doll.mousecapture_on:
		camera_rotation_euler += Vector3(doll_controls.mouse_movement.y, doll_controls.mouse_movement.x, 0) * _doll.LOOK_SENSITIVITY
	camera_rotation_euler.x = clamp(camera_rotation_euler.x, _doll.LOOK_LIMIT_LOWER, _doll.LOOK_LIMIT_UPPER)
	
	_doll.camera_rotation = Quaternion.from_euler(camera_rotation_euler)
	CameraPivot.basis = Basis(_doll.camera_rotation)
	_doll.camera_rotation_no_y = Basis(CameraPivot.basis.x, Vector3.UP, CameraPivot.basis.z).get_rotation_quaternion()
	
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

func processHit(_attackContext:AttackContext):
	#var theAttack := _attackContext.attack
	#var theDamageMult:float = theAttack.damage
	if(isBlocking() && CombatMovePlayer.isInCone(_attackContext.target, _attackContext.attacker, 90.0)):
		_attackContext.blocked = true
	
	var theCharacter := pawn.getCharacter()
	if(theCharacter):
		theCharacter.processHit(_attackContext)
	
	var theDoll := getDoll()
	if(theDoll):
		onDollHit(theDoll, _attackContext)

func onDollHit(_doll:DollController, _attackContext:AttackContext):
	#_doll.applyHitRandom(2.0)
	var theDir:Vector3 = _attackContext.attacker.getGlobalPos() - _attackContext.target.getGlobalPos()
	
	var theRecoil:float = sqrt(_attackContext.attack.damage*1.0)*2.0 if _attackContext.attack.damage > 0.0 else 0.0
	if(_attackContext.blocked):
		theRecoil *= 0.4
	
	_doll.getDoll().applyHitSpecific(theRecoil, theDir, true, Doll.HIT_AREA_MIDDLE)

func shouldShowCombatUI() -> bool:
	return false

func isTryingToBlock() -> bool:
	return false

func isBlocking() -> bool:
	return pawn.combatMovePlayer.isBlocking()
