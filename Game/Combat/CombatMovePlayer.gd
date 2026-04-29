extends Node
class_name CombatMovePlayer

var pawn:CharacterPawn

var combatMove:CombatMoveBase
var moveTime:float = 0.0
var noMoveTimer:float = 0.0
var noAttackTimer:float = 0.0
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

@export var blocking:bool = false
@export var defeatRecovery:float = 0.0

@export var exhaustion:float = 0.0
var exhaustionRecovery:float = 0.0 # Timer until the exhaustion starts going down again

@export var strain:float = 0.0
var strainRecovery:float = 0.0 # Timer until the strain starts going down again

var dodgeAllTimer:float = 0.0 # all attacks miss us, invincibility frames

var staggerImmunity:float = 0.0 # Prevents all stuns and collapses

const CURVE_TO_RESOURCE:Dictionary[int, Curve] = {
	CURVE_SMOOTH: RESOURCE_CURVE_SMOOTH,
	CURVE_EASE_IN: RESOURCE_CURVE_EASE_IN,
}

func setPawn(_p:CharacterPawn):
	pawn = _p

func onDefeat():
	defeatRecovery = 7.0

func onCollapse():
	pass

func canActivateTrigger(_act:int) -> bool:
	var theBuffsHolder := pawn.getBuffsHolder()
	if(!theBuffsHolder):
		return false
	if(_act == CombatMoveBase.ACTIVATE_ATTACK1):
		if(theBuffsHolder.hasBoundArms()):
			return false
	if(_act == CombatMoveBase.ACTIVATE_SHIFT):
		if(theBuffsHolder.hasBoundLegs()):
			return false
	if(_act == CombatMoveBase.ACTIVATE_SPACE):
		if(theBuffsHolder.hasBoundLegs()):
			return false
	
	return true

func activateTrigger(_act:int) -> bool:
	if(!pawn.canDoCombatMoves()):
		return false
	if(!canActivateTrigger(_act)):
		return false
	
	var allMoves := GlobalRegistry.getCombatMovesByActivationType(_act)
	if(allMoves.is_empty()):
		return false
	
	for theMove in allMoves: # Sorted by priority
		if(!theMove.canUseMoveFinal(self)):
			continue
		
		startMove(theMove)
		return true
	
	if(isExhausted() && pawn.isControlledByUs()):
		Audio.playSoundAdvanced(preload("res://Sounds/Combat/Misc/DenyNoise.tres"), 0.0)
	
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
	#Log.Print("STARTED MOVE: "+str(_move.id))
	processEffectQueue(0.0) # Forces the initial effects to trigger
	
	for otherPawnInteractor in pawn.pawn_interactor.nearbyPawns:
		otherPawnInteractor.pawn.onNearbyPawnStartMove(pawn, _move)

func cancelCurrentMove():
	if(combatMove):
		combatMove.onCancel(self)
		moveTime = 0.0

func pushToEffectsQueue(_ar:Array):
	effects.append_array(_ar)

func processCombatPlayer(_dt:float):
	if(Network.isClient()):
		return
	
	processEffectQueue(_dt)
	#if(!activeTags.is_empty()):
	#	Log.Print(str(activeTags))
	for tagID in activeTags.keys():
		activeTags[tagID] -= _dt
		if(activeTags[tagID] <= 0.0):
			activeTags.erase(tagID)
	if(noMoveTimer > 0.0):
		noMoveTimer -= _dt
	if(noAttackTimer > 0.0):
		noAttackTimer -= _dt
	if(velTimeFull > 0.0):
		velTime += _dt
		if(velTime >= velTimeFull):
			resetVel()
	if(combatMove):
		moveTime += _dt
		if(moveTime >= combatMove.moveLen):
			if(effects.is_empty()): # Try to stop the move
				stopMove()
	if(defeatRecovery > 0.0):
		defeatRecovery -= _dt
	
	blocking = pawn.state.isBlocking()
	
	processExhaustionAndStrain(_dt)

func stopMove():
	#Log.Print("MOVE STOPPED: "+str(combatMove.id if combatMove else "null"))
	combatMove = null
	moveTime = 0.0
	effects.clear()

func isBlocking() -> bool:
	return blocking

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
				combatMove.onStrike(self, curEffectAr[1],
					curEffectAr[2] if curEffectAr.size() > 2 else combatMove.EFFECTS_NOTHING,
					curEffectAr[3] if curEffectAr.size() > 3 else combatMove.INTENSITY_NORMAL)
		elif(curEffectType == CombatMoveBase.EFFECT_TAG):
			effects.pop_front()
			pushTag(curEffectAr[1], curEffectAr[2])
		elif(curEffectType == CombatMoveBase.EFFECT_MOVE):
			effects.pop_front()
			setVel(curEffectAr[1], curEffectAr[2])
		elif(curEffectType == CombatMoveBase.EFFECT_SOUND):
			effects.pop_front()
			doSoundEffect(curEffectAr[1])
		elif(curEffectType == CombatMoveBase.EFFECT_EXHAUSTION):
			effects.pop_front()
			causeExhaustion(curEffectAr[1])
		elif(curEffectType == CombatMoveBase.EFFECT_DODGE_ALL_ATTACKS):
			effects.pop_front()
			makeImpossibleToHit(curEffectAr[1])

func doSoundEffect(_effectID:int):
	if(_effectID == CombatMoveBase.SOUND_FALL):
		Audio.playSound3DAdvanced(pawn, preload("res://Sounds/Combat/Fall/FallRandom.tres"), -10.0)
	if(_effectID == CombatMoveBase.SOUND_DODGE):
		Audio.playSound3DAdvanced(pawn, preload("res://Sounds/Combat/Whoosh/Whoosh.tres"), -10.0, 1.0)
	
	if(Network.isServerNotSingleplayer()):
		Network.rpcClients(doSoundEffect_RPC.bind(_effectID))

@rpc("authority", "call_remote", "unreliable")
func doSoundEffect_RPC(_effectID:int):
	doSoundEffect(_effectID)

func pushTag(_tag:String, _time:float):
	activeTags[_tag] = _time

func hasTag(_tag:String) -> bool:
	return activeTags.has(_tag)

func eraseTag(_tag:String):
	activeTags.erase(_tag)

func canMove() -> bool:
	return noMoveTimer <= 0.0

func makeNoMove(_time:float):
	noMoveTimer = maxf(noMoveTimer, _time)

func makeNoAttack(_time:float):
	noAttackTimer = maxf(noAttackTimer, _time)

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

func isMovingByAnAttack() -> bool:
	return velTimeFull > 0.0

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

const Y_HIT_SQUISH := 0.3

func willHitTarget(thePawn:CharacterPawn, _maxDist:float, _maxSpread:float) -> bool:
	var ourPos:Vector3 = pawn.getGlobalPos()
	var ourRotY:float = pawn.getYRotation()
	var ourForward := Vector3(0,0,-1).rotated(Vector3.UP, ourRotY)
	var cosThreshold := cos(deg_to_rad(_maxSpread))
	var distSquared:float = _maxDist*_maxDist
	
	var theirPos:Vector3 = thePawn.getGlobalPos()
	if(theirPos.distance_squared_to(ourPos) > distSquared):
		return false
	var theDir := ourPos - theirPos
	theDir.y *= Y_HIT_SQUISH
	var theDot := ourForward.dot(theDir.normalized())
	if(theDot < cosThreshold): #!isInCone(ourPos, ourRotY, theirPos, _maxSpread)
		return false
	
	return true

func willAttackHitTarget(_thePawn:CharacterPawn, _attackInfo:AttackInfo, _distMult:float = 1.2, _spreadMult:float = 1.2) -> bool:
	return willHitTarget(_thePawn, _attackInfo.reach*_distMult, _attackInfo.spread*_spreadMult)

# if _getAll = false, the function will try to get only the most in-front-of-us target (unless there are many)
func getTargets(_maxDist:float, _maxSpread:float, _getAll:bool = true, _ignoreImpossible:bool = false, _checkIgnoreHit:bool = true) -> Array[CharacterPawn]:
	var result:Array[CharacterPawn]
	
	var ourPos:Vector3 = pawn.getGlobalPos()
	var ourRotY:float = pawn.getYRotation()
	var ourForward := Vector3(0,0,-1).rotated(Vector3.UP, ourRotY)
	var cosThreshold := cos(deg_to_rad(_maxSpread))
	#print("FORWRD: ",forward)
	
	var maxDot:float = -99.0
	
	var distSquared:float = _maxDist*_maxDist
	var nearbyInteractors := pawn.getNearbyPawnInteractors()
	for theInteractor in nearbyInteractors:
		var thePawn := theInteractor.pawn
		if(!_ignoreImpossible && thePawn.combatMovePlayer.isImpossibleToHit()):
			continue
		if(_checkIgnoreHit && pawn.shouldIgnoreAttackTowards(thePawn)):
			continue
		var theirPos:Vector3 = thePawn.getGlobalPos()
		if(theirPos.distance_squared_to(ourPos) > distSquared):
			continue
		var theDir := ourPos - theirPos
		theDir.y *= Y_HIT_SQUISH
		var theDot := ourForward.dot(theDir.normalized())
		if(theDot < cosThreshold): #!isInCone(ourPos, ourRotY, theirPos, _maxSpread)
			continue
		#var theDirAng:float = ourPos.angle_to(theirPos)
		#print(theDot, " ",cosThreshold)
		
		if(_getAll):
			result.append(thePawn)
		else:
			var theDiff := absf(maxDot - theDot)
			
			if(theDiff < 0.05 && !result.is_empty()):
				result.append(thePawn)
			elif(theDot > maxDot):
				maxDot = theDot
				result.append(thePawn)
	
	return result

func getTargetsForAttack(_attackInfo:AttackInfo) -> Array[CharacterPawn]:
	if(!_attackInfo):
		assert(false, "NULL ATTACK INFO SUPPLIED TO getTargetsForAttack()!")
		return []
	return getTargets(_attackInfo.reach, _attackInfo.spread, _attackInfo.hitAll)

func doFakeStrike(_otherPawn:CharacterPawn, _damage:float):
	if(!_otherPawn):
		return
	var newAttack:AttackInfo = AttackInfo.new()
	newAttack.damage = _damage
	
	var theContext:AttackContext = AttackContext.new()
	theContext.attacker = pawn
	theContext.attack = newAttack
	theContext.target = _otherPawn
	
	theContext.blocked = RNG.chance(30.0) && _otherPawn.canBlock()
	
	var _theStatus := _otherPawn.processHit(theContext)
	#Log.Print("DID FAKE ATTACK FOR "+str(newAttack.damage)+" DAMAGE")

func doStrike(_attackInfo:AttackInfo, _effects:AttackEffects, _intensity:int):
	var theTargets := getTargetsForAttack(_attackInfo)
	
	var theContext:AttackContext = AttackContext.new()
	theContext.attacker = pawn
	theContext.attack = _attackInfo
	
	var hitStatus:int = AttackEffects.STATUS_MISSED
	var _strain:float = 0.0
	
	var anyHits:bool = false
	var anyBlocked:bool = false
	for thePawn in theTargets:
		theContext.target = thePawn
		var theStatus := thePawn.processHit(theContext)
		
		if(theStatus == AttackEffects.STATUS_HIT):
			anyHits = true
		elif(theStatus == AttackEffects.STATUS_BLOCKED):
			anyBlocked = true
			_strain = maxf(_strain, thePawn.combatMovePlayer.getStrainLevel())
	
	if(anyBlocked):
		hitStatus = AttackEffects.STATUS_BLOCKED
	if(anyHits):
		hitStatus = AttackEffects.STATUS_HIT
	
	doAttackEffects(_effects, hitStatus, _intensity, _strain)
	for thePawn in theTargets:
		var theDir:Vector3 = pawn.getGlobalPos() - thePawn.getGlobalPos()
		thePawn.combatMovePlayer.doReceiveAttackEffects(theDir, theContext.attack.damage, theContext.blocked)
	
	if(anyBlocked):
		causeExhaustion(_attackInfo.exhaustionBlocked)
	elif(anyHits):
		causeExhaustion(_attackInfo.exhaustionHit)
	else:
		causeExhaustion(_attackInfo.exhaustion)
	
	#causeExhaustion(0.1)

func onHit(_attackContext:AttackContext):
	var theAttack := _attackContext.attack
	
	if(_attackContext.blocked):
		causeStrain(theAttack.strain)
	makeImpossibleToHit(theAttack.dodgeTimeForTarget)
	
	var didSomething:bool = false
	if(theAttack.collapsesTarget && pawn.state.canCollapse()):
		var theVuln:float = pawn.calculateCombatVulnerability()
		if(theVuln >= theAttack.collapseMinVulnerability):
			var theDir := _attackContext.target.getGlobalPos() - _attackContext.attacker.getGlobalPos()
			theDir = theDir.normalized()
			pawn.sendFlying(theDir*theAttack.collapseBackVelocity, theAttack.collapseUpVelocity)
			didSomething = true
	if(!didSomething && theAttack.staggerTarget && pawn.state.canCollapse()):
		var theVuln:float = pawn.calculateCombatVulnerability()
		if(theVuln >= theAttack.staggerMinVulnerability):
			pawn.doStagger()
			didSomething = true
	
	# Block break
	if(!didSomething && (theAttack.collapsesTarget || theAttack.staggerTarget) && pawn.state.canCollapse() && getExhaustionLevel() >= 1.0 && getStrainLevel() >= 1.0 && pawn.isBlocking()):
		if(theAttack.collapsesTarget):
			var theDir := _attackContext.target.getGlobalPos() - _attackContext.attacker.getGlobalPos()
			theDir = theDir.normalized()
			pawn.sendFlying(theDir*theAttack.collapseBackVelocity, theAttack.collapseUpVelocity)
			didSomething = true
		#elif(theAttack.staggerTarget):
		else:
			pawn.doStagger()
			didSomething = true

func intensityToPitch(_intensity:int) -> float:
	if(_intensity == CombatMoveBase.INTENSITY_SOFT):
		return 1.3
	if(_intensity == CombatMoveBase.INTENSITY_STRONG):
		return 0.9
	return 1.0

func doAttackEffects(_effects:AttackEffects, _hitStatus:int, _intensity:int, _strain:float):
	#Log.Print(str(_effects.zoneAttacking))
	if(_effects.impactEffect != AttackEffects.EFFECT_NO_EFFECT):
		var theDoll := getDoll()
		if(theDoll):
			var theDollSkeleton := theDoll.getDoll().getBodySkeleton()
			var nodeToAttachTo:Node3D
			var hitNode:Node3D
			var theZone:int = _effects.zoneAttacking
			if(theZone == AttackEffects.ZONE_FIST_LEFT):
				nodeToAttachTo = theDollSkeleton.punch_vfx_spot_l
				hitNode = theDollSkeleton.punch_hit_vfxl
			elif(theZone == AttackEffects.ZONE_FIST_RIGHT):
				nodeToAttachTo = theDollSkeleton.punch_vfx_spot_r
				hitNode = theDollSkeleton.punch_hit_vfxr
			elif(theZone == AttackEffects.ZONE_FOOT_LEFT):
				nodeToAttachTo = theDollSkeleton.kick_vfx_spot_l
				hitNode = theDollSkeleton.kick_vfx_spot_l
			elif(theZone == AttackEffects.ZONE_FOOT_RIGHT):
				nodeToAttachTo = theDollSkeleton.kick_vfx_spot_r
				hitNode = theDollSkeleton.kick_vfx_spot_r
			
			if(_hitStatus == AttackEffects.STATUS_BLOCKED && nodeToAttachTo):
				var newPunch := preload("res://Mesh/VFX/Parts/VFXDrop.tscn").instantiate()
				nodeToAttachTo.add_child(newPunch)
				#newPunch.setMaterial(preload("res://Mesh/VFX/Mats/ImpactMat.tres"))
				newPunch.fadeInOut(0.05, 0.2 * AttackEffects.getEffectTimeMultFromZone(theZone))
			if(_hitStatus == AttackEffects.STATUS_HIT && hitNode):
			#if(hitNode):
				var newHit := preload("res://Mesh/VFX/Parts/HitParticles.tscn").instantiate()
				hitNode.add_child(newHit)
			
	var thePitch := intensityToPitch(_intensity)
	if(_hitStatus == AttackEffects.STATUS_MISSED):
		#if(_intensity == CombatMoveBase.INTENSITY_SOFT):
		#	Audio.playSound3DAdvanced(pawn, preload("res://Sounds/Combat/Miss/MissHigh.tres"), -25.0, 1.2)
		#elif(_intensity == CombatMoveBase.INTENSITY_STRONG):
		#	Audio.playSound3DAdvanced(pawn, preload("res://Sounds/Combat/Miss/MissLow.tres"), -25.0, 0.8)
		#else:
		#Log.Print("MISS!!! "+str(pawn))
		if(_effects.impactSound == _effects.SOUND_KICK):
			Audio.playSound3DAdvanced(pawn, preload("res://Sounds/Combat/Miss/MissLow.tres"), -20.0, 0.5)
		else:
			Audio.playSound3DAdvanced(pawn, preload("res://Sounds/Combat/Miss/MissMedium.tres"), -25.0, 1.0)
	if(_hitStatus == AttackEffects.STATUS_BLOCKED):
		var pitchMod:float = 1.0
		if(_strain >= 0.5):
			var theProg:float = remap(_strain, 0.5, 1.0, 0.0, 1.0)
			pitchMod = (1.0 - _strain*0.5)
			Audio.playSound3DAdvanced(pawn, preload("res://Sounds/Combat/Blocked/BlockedStrain.tres"), -30.0 + theProg*20.0, 1.0 + theProg*0.5)
		#print(_strain, " ",pitchMod)
		
		Audio.playSound3DAdvanced(pawn, preload("res://Sounds/Combat/Blocked/BlockedHit.tres"), -0.0, thePitch*pitchMod)
	if(_hitStatus == AttackEffects.STATUS_HIT):
		if(_effects.impactSound == _effects.SOUND_PUNCH):
			Audio.playSound3DAdvanced(pawn, preload("res://Sounds/Combat/Punch/PunchRandom.tres"), -0.0, thePitch)
		if(_effects.impactSound == _effects.SOUND_KICK):
			Audio.playSound3DAdvanced(pawn, preload("res://Sounds/Combat/Punch/KickRandom.tres"), -5.0, thePitch)

	if(Network.isServerNotSingleplayer()):
		Network.rpcClients(doAttackEffects_RPC.bind(_effects.saveNetworkData().getBytes(), _hitStatus, _intensity, _strain))
	
@rpc("authority", "call_remote", "reliable")
func doAttackEffects_RPC(_effectsData:PackedByteArray, _hitStatus:int, _intensity:int, _strain:float):
	var attackEffects:AttackEffects = AttackEffects.new()
	attackEffects.loadNetworkData(Bins.readUncompressed(_effectsData))
	
	doAttackEffects(attackEffects, _hitStatus, _intensity, _strain)
	
func doReceiveAttackEffects(_dir:Vector3, _flinch:float, _blocked:bool):
	var theRecoil:float = sqrt(_flinch)*3.0 if _flinch > 0.0 else 0.0
	if(_blocked):
		theRecoil *= 0.4
	if(pawn.getDoll()):
		pawn.getDoll().getDoll().applyHitSpecific(theRecoil, _dir, true, Doll.HIT_AREA_MIDDLE)
	
	if(Network.isServerNotSingleplayer()):
		Network.rpcClients(doReceiveAttackEffects_RPC.bind(_dir, _flinch, _blocked))

@rpc("authority", "call_remote", "reliable")
func doReceiveAttackEffects_RPC(_dir:Vector3, _flinch:float, _blocked:bool):
	doReceiveAttackEffects(_dir, _flinch, _blocked)

func isTryingToBlock() -> bool:
	return pawn.state.isTryingToBlock() && canBlock()

func canBlock() -> bool:
	if(isDoingAMove()):
		return false
	if(noAttackTimer > 0.0):
		return false
	if(pawn.getBuffsHolder().hasBoundArms()):
		return false
	
	return true

func canDodge() -> bool:
	if(isExhausted()):
		return false
	if(!canUseMoveID("Dodge")):
		return false
	if(pawn.getBuffsHolder().hasBoundLegs()):
		return false
	return true
	
func canUseMoveID(_moveID:String) -> bool:
	var theMove := GlobalRegistry.getCombatMove(_moveID)
	if(!theMove):
		return false
	return theMove.canUseMoveFinal(self)

func shouldFollowMoveDirection() -> bool:
	if(!isDoingAMove()):
		return false
	
	return combatMove.followVelocityDir

func canRecoverFromDefeat() -> bool:
	return defeatRecovery <= 0.0

func getExhaustionLimit() -> float:
	return 1.0

func getExhaustionLevel() -> float:
	var theLevel := getExhaustionLimit()
	if(theLevel <= 0.0):
		return 0.0
	return clamp(exhaustion / theLevel, 0.0, 1.0)

func getExhaustion() -> float:
	return exhaustion

func addExhaustion(_e:float):
	exhaustion += _e
	exhaustion = clampf(exhaustion, 0.0, getExhaustionLimit())

func getExhaustionRecoveryNewTime() -> float:
	return 1.5

func causeExhaustion(_e:float) -> bool:
	if(_e == 0.0):
		return false
	var oldExhaustion := exhaustion
	addExhaustion(_e)
	exhaustionRecovery = maxf(exhaustionRecovery, getExhaustionRecoveryNewTime())
	
	if(oldExhaustion == exhaustion):
		return false
	return true

func isExhausted() -> bool:
	return exhaustion >= getExhaustionLimit()

func isImpossibleToHit() -> bool:
	return dodgeAllTimer > 0.0

func processExhaustionAndStrain(_dt:float):
	if(dodgeAllTimer > 0.0):
		dodgeAllTimer -= _dt
	if(staggerImmunity > 0.0):
		staggerImmunity -= _dt
	
	if(strain > 0.0):
		if(strainRecovery > 0.0):
			if(!isBlocking()):
				strainRecovery -= _dt
		else:
			var strainRegenMult:float = 1.0
			#if(pawn.getDoll() && pawn.getDoll().isRunning):
			#	exhaustionRegenMult *= 0.2
			
			addStrain(-_dt*strainRegenMult)
	
	if(exhaustion > 0.0):
		if(exhaustionRecovery > 0.0):
			if(!isDoingAMove()):
				exhaustionRecovery -= _dt
		else:
			var exhaustionRegenMult:float = 1.0
			if(pawn.getDoll() && pawn.getDoll().isRunning):
				exhaustionRegenMult *= 0.2
			if(isBlocking()):
				exhaustionRegenMult *= 0.5
			
			addExhaustion(-_dt*exhaustionRegenMult)

func getStrainLimit() -> float:
	return 1.0

func addStrain(_st:float):
	strain += _st
	strain = clampf(strain, 0.0, getStrainLimit())

func causeStrain(_st:float, _overflowIntoExhaustion:bool = true) -> bool:
	if(_st == 0.0):
		return false
	var oldStrain := strain
	addStrain(_st)
	strainRecovery = maxf(strainRecovery, 1.0)
	
	if(_st > 0.0 && _overflowIntoExhaustion):
		var _diff:float = -strain + oldStrain + _st
		if(_diff > 0.0):
			causeExhaustion(_diff*2.0) # 2.0 is a magic number?
	
	if(oldStrain == strain):
		return false
	return true

func getStrain() -> float:
	return strain

func getStrainLevel() -> float:
	var theLevel := getStrainLimit()
	if(theLevel <= 0.0):
		return 0.0
	return clamp(strain / theLevel, 0.0, 1.0)

func getStrainHaveEffectLevel() -> float:
	return 0.5

func makeImpossibleToHit(_time:float):
	dodgeAllTimer = maxf(_time, dodgeAllTimer)

func doStagger():
	pawn.doCombatAnim("GettingHitStrong", true)
	stopMove()
	makeNoMove(1.1)
	makeNoAttack(1.0)
	#resetVel()
	vel *= 0.5
	giveStaggerImmunity(1.5)
	
func giveStaggerImmunity(_t:float):
	staggerImmunity = maxf(_t, staggerImmunity)

func hasStaggerImmunity() -> bool:
	return staggerImmunity > 0.0

# returns [time, attackInfo] or []
func getClosestHitEntry() -> Array:
	if(effects.is_empty()):
		return []
	var theTime:float = 0.0
	for effectEntry in effects:
		if(effectEntry[0] == CombatMoveBase.EFFECT_DELAY):
			theTime += effectEntry[1]
		if(effectEntry[0] == CombatMoveBase.EFFECT_HIT):
			return [theTime, effectEntry[1]]
	return []
