extends Node
class_name CombatMovePlayer

var pawn:CharacterPawn

var combatMove:CombatMoveBase
var moveTime:float = 0.0
var noMoveTimer:float = 0.0
var effects:Array
var activeTags:Dictionary[String, float]

var vel:Vector3
var velTime:float = 0.0
var velTimeFull:float = 0.0
var velCurve:int = CURVE_SMOOTH

const CURVE_SMOOTH = 0
const RESOURCE_CURVE_SMOOTH = preload("res://Game/Combat/Curves/Smooth.tres")
const CURVE_EASE_IN = 1
const RESOURCE_CURVE_EASE_IN = preload("res://Game/Combat/Curves/EaseIn.tres")


const CURVE_TO_RESOURCE:Dictionary[int, Curve] = {
	CURVE_SMOOTH: RESOURCE_CURVE_SMOOTH,
	CURVE_EASE_IN: RESOURCE_CURVE_EASE_IN,
}

func setPawn(_p:CharacterPawn):
	pawn = _p

func activateTrigger(_act:int) -> bool:
	if(!pawn.canDoCombatMoves()):
		return false
	
	var allMoves := GlobalRegistry.getCombatMovesByActivationType(_act)
	if(allMoves.is_empty()):
		return false
	
	for theMove in allMoves: # Sorted by priority
		if(!theMove.canUseMoveFinal(self)):
			continue
		
		startMove(theMove)
		return true
	
	return false

func startMove(_move:CombatMoveBase):
	moveTime = 0.0
	noMoveTimer = _move.noMoveLen
	effects.clear()
	
	cancelCurrentMove()
	combatMove = _move
	
	if(!_move):
		return
	_move.startMove(self)
	Log.Print("STARTED MOVE: "+str(_move.id))
	processEffectQueue(0.0) # Forces the initial effects to trigger

func cancelCurrentMove():
	if(combatMove):
		combatMove.onCancel(self)
		moveTime = 0.0

func pushToEffectsQueue(_ar:Array):
	effects.append_array(_ar)

func processCombatPlayer(_dt:float):
	processEffectQueue(_dt)
	#if(!activeTags.is_empty()):
	#	Log.Print(str(activeTags))
	for tagID in activeTags.keys():
		activeTags[tagID] -= _dt
		if(activeTags[tagID] <= 0.0):
			activeTags.erase(tagID)
	if(noMoveTimer > 0.0):
		noMoveTimer -= _dt
	if(velTimeFull > 0.0):
		velTime += _dt
		if(velTime >= velTimeFull):
			resetVel()
	if(combatMove):
		moveTime += _dt
		if(moveTime >= combatMove.moveLen):
			if(effects.is_empty()): # Try to stop the move
				stopMove()

func stopMove():
	Log.Print("MOVE STOPPED: "+str(combatMove.id if combatMove else "null"))
	combatMove = null
	moveTime = 0.0
	effects.clear()

func processEffectQueue(_dt:float):
	while(!effects.is_empty()):
		var curEffectAr:Array = effects[0]
		var curEffectType:int = curEffectAr[0]
		
		if(curEffectType == CombatMoveBase.EFFECT_DELAY):
			curEffectAr[1] -= _dt
			if(curEffectAr[1] > 0.0):
				return
			#Log.Print("DELAY ENDED!")
			effects.pop_front()
		elif(curEffectType == CombatMoveBase.EFFECT_EVENT):
			effects.pop_front()
			if(combatMove):
				combatMove.onEvent(self, curEffectAr[1], curEffectAr[2] if curEffectAr.size() > 2 else [])
		elif(curEffectType == CombatMoveBase.EFFECT_HIT):
			effects.pop_front()
			if(combatMove):
				combatMove.onStrike(self, curEffectAr[1])
		elif(curEffectType == CombatMoveBase.EFFECT_TAG):
			effects.pop_front()
			pushTag(curEffectAr[1], curEffectAr[2])
		elif(curEffectType == CombatMoveBase.EFFECT_MOVE):
			effects.pop_front()
			setVel(curEffectAr[1], curEffectAr[2])
		
func pushTag(_tag:String, _time:float):
	activeTags[_tag] = _time

func hasTag(_tag:String) -> bool:
	return activeTags.has(_tag)

func eraseTag(_tag:String):
	activeTags.erase(_tag)

func canMove() -> bool:
	return noMoveTimer <= 0.0

func isDoingAMove() -> bool:
	if(combatMove):
		return true
	return false

# Some kind of curve?
func setVel(_vel:Vector3, _time:float):
	vel = _vel
	velTime = 0.0
	velTimeFull = _time

func resetVel():
	vel = Vector3.ZERO
	velTime = 0.0
	velTimeFull = 0.0

func getFinalVel() -> Vector3:
	return CURVE_TO_RESOURCE.get(velCurve, RESOURCE_CURVE_SMOOTH).sample(velTime/velTimeFull)*vel

func getDoll() -> DollController:
	return pawn.getDoll()

func getCurrentLocalVelNoY() -> Vector3:
	var theDoll := getDoll()
	if(!theDoll):
		return Vector3.ZERO
	var theLocalVel := theDoll.getLocalVelocity()
	theLocalVel.y = 0.0
	return theLocalVel

func getCurrentControlsDir() -> Vector3:
	var theDoll := getDoll()
	if(!theDoll):
		return Vector3.ZERO
	var theLocalVel := theDoll.doll_controls.input_dir
	#theLocalVel.y = 0.0
	return Vector3(-theLocalVel.x, 0.0, -theLocalVel.y)

static func isInConeRaw(_pos1:Vector3, _rot1:float, _pos2:Vector3, _maxSpreadDeg:float) -> bool:
	var ourForward := Vector3(0,0,-1).rotated(Vector3.UP, _rot1)
	var cosThreshold := cos(deg_to_rad(_maxSpreadDeg))
	
	var theDir := _pos1 - _pos2
	var theDot := ourForward.dot(theDir.normalized())
	if(theDot < cosThreshold):
		return false
	return true

static func isInCone(_pawnFrom:CharacterPawn, _pawnTo:CharacterPawn, _maxSpreadDeg:float) -> bool:
	var ourPos:Vector3 = _pawnFrom.getGlobalPos()
	var ourRotY:float = _pawnFrom.getYRotation()
	var theirPos:Vector3 = _pawnTo.getGlobalPos()
	
	return isInConeRaw(ourPos, ourRotY, theirPos, _maxSpreadDeg)

func getTargets(_maxDist:float, _maxSpread:float) -> Array[CharacterPawn]:
	var result:Array[CharacterPawn]
	
	var ourPos:Vector3 = pawn.getGlobalPos()
	var ourRotY:float = pawn.getYRotation()
	var ourForward := Vector3(0,0,-1).rotated(Vector3.UP, ourRotY)
	var cosThreshold := cos(deg_to_rad(_maxSpread))
	#print("FORWRD: ",forward)
	
	var distSquared:float = _maxDist*_maxDist
	var nearbyInteractors := pawn.getNearbyPawnInteractors()
	for theInteractor in nearbyInteractors:
		var thePawn := theInteractor.pawn
		var theirPos:Vector3 = thePawn.getGlobalPos()
		if(theirPos.distance_squared_to(ourPos) > distSquared):
			continue
		var theDir := ourPos - theirPos
		var theDot := ourForward.dot(theDir.normalized())
		if(theDot < cosThreshold): #!isInCone(ourPos, ourRotY, theirPos, _maxSpread)
			continue
		#var theDirAng:float = ourPos.angle_to(theirPos)
		#print(theDot, " ",cosThreshold)
		
		result.append(thePawn)
	
	return result

func getTargetsForAttack(_attackInfo:AttackInfo) -> Array[CharacterPawn]:
	return getTargets(_attackInfo.reach, _attackInfo.spread)

func doStrike(_attackInfo:AttackInfo):
	var theTargets := getTargetsForAttack(_attackInfo)
	
	var theContext:AttackContext = AttackContext.new()
	theContext.attacker = pawn
	theContext.attack = _attackInfo
	
	for thePawn in theTargets:
		theContext.target = thePawn
		thePawn.processHit(theContext)

func isBlocking() -> bool:
	return pawn.state.isTryingToBlock() && canBlock()

func canBlock() -> bool:
	if(isDoingAMove()):
		return false
	
	return true

func shouldFollowMoveDirection() -> bool:
	if(!isDoingAMove()):
		return false
	
	return combatMove.followVelocityDir
