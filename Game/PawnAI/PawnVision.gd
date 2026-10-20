extends RefCounted
class_name PawnVision

var memory:Dictionary[CharacterPawn, MaybeSeenPawn] = {}
var pawn:CharacterPawn
var hostile:bool = false # If hostile, we look further
var blind:bool = false

var seePawns:Array[CharacterPawn] = []

func saveData() -> Dictionary:
	var memoryData:Array = []
	for thePawn:CharacterPawn in memory:
		var theSeen:MaybeSeenPawn = memory[thePawn]
		if(theSeen.shouldRemove):
			continue
		memoryData.append({
			id = thePawn.getID(),
			s = theSeen.seen,
			t = theSeen.time,
			d = theSeen.detection,
			rh = theSeen.rememberHostile,
			stf = theSeen.seenThisFrame,
		})
	return {
		memory = memoryData,
	}

# Must be loaded late
func loadData(_data:Dictionary):
	checkHostileStatus()
	
	memory.clear()
	seePawns.clear()
	
	var memoryData:Array[Dictionary] = SAVE.loadArrayOfDicts(_data, "memory")
	for theEntry:Dictionary in memoryData:
		var theID:String = SAVE.loadStr(theEntry, "id")
		var thePawn:CharacterPawn = GM.pawnRegistry.getPawn(theID)
		if(!thePawn):
			continue
		var newSeen:MaybeSeenPawn = MaybeSeenPawn.new()
		newSeen.vision = weakref(self)
		newSeen.seen = SAVE.loadBool(theEntry, "s")
		newSeen.time = SAVE.loadFloat(theEntry, "t")
		newSeen.detection = SAVE.loadFloat(theEntry, "d")
		newSeen.rememberHostile = SAVE.loadBool(theEntry, "rh")
		newSeen.seenThisFrame = SAVE.loadFloat(theEntry, "stf")
		
		thePawn.onPawnDelete.connect(newSeen.onPawnDelete.bind(thePawn))
		memory[thePawn] = newSeen
		if(newSeen.seen):
			seePawns.append(thePawn)

class MaybeSeenPawn:
	var vision:WeakRef
	var seen:bool = false # rename to aware?
	var time:float = 0.0 # Amounts of seconds since we have last seen the pawn
	var detection:float = 0.0 # if >= 1.0, we've detected this pawn
	#var raycastCooldown:float = 0.0 # To prevent shooting a raycat every frame
	#var raycastResult:bool = false
	var rememberHostile:bool = false # If our status changes from non-hostile to hostile, we gotta reset the seen/detection
	
	var seenThisFrame:float = 0.0 # How seen are we this frame
	var shouldRemove:bool = false
	
	func onPawnDelete(_pawn:CharacterPawn):
		var theVision:PawnVision = vision.get_ref()
		if(theVision):
			theVision.onSeenPawnDeleted(_pawn)
			#theVision.memory.erase(_pawn)
		shouldRemove = true

func onSeenPawnDeleted(_pawn:CharacterPawn):
	memory.erase(_pawn)
	seePawns.erase(_pawn)

func setPawn(_thePawn:CharacterPawn):
	assert(!pawn, "Pawn already assigned!")
	pawn = _thePawn
	pawn.onPawnDelete.connect(func():
		pawn = null
	)

func getPawn() -> CharacterPawn:
	return pawn

func getDoll() -> DollController:
	if(!pawn):
		return null
	return pawn.getDoll()

func checkHostileStatus():
	hostile = pawn.isInCombat()
	blind = pawn.calculateIsBlind()

var toRem:Array[CharacterPawn]
func processVision(_dt:float):
	if(!pawn):
		return
	if(pawn.isControlledByAnyPlayer()): # Remove when its working?
		memory.clear()
		checkHostileStatus()
		return
	checkHostileStatus()
	
	var _nearbyPawns := GM.pawnRegistry.getPawnsNearDict(pawn.global_position, getCurrentVisionDistance())
	
	for thePawn:CharacterPawn in memory:
		var theSeen := memory[thePawn]
		if(_nearbyPawns.has(thePawn)):
			theSeen.seenThisFrame = getVisionScore(thePawn, theSeen)
		#	theSeen.time = 0
		#	theSeen.detection += _dt
			_nearbyPawns.erase(thePawn)
			
			if(!theSeen.rememberHostile && doesPawnRequireRaycast(thePawn)):
				# If we became an enemy mid-detection, reset it
				# Because the old data was gathered without raycasts
				theSeen.rememberHostile = true
				theSeen.seen = false
				theSeen.detection = 0.0
				theSeen.time = 0.0
			elif(theSeen.rememberHostile && !doesPawnRequireRaycast(thePawn)):
				theSeen.rememberHostile = false
		else:
			theSeen.seenThisFrame = 0.0
		#	theSeen.time += _dt
		#	theSeen.detection -= _dt
	
	for _newPawn:CharacterPawn in _nearbyPawns:
		if(_newPawn == pawn): # Ignore ourselves
			continue
		var theVisionScore:float = getVisionScore(_newPawn, null)
		if(theVisionScore <= 0.0):
			continue
		var newSeen := MaybeSeenPawn.new()
		newSeen.seenThisFrame = theVisionScore
		newSeen.vision = weakref(self)
		newSeen.rememberHostile = doesPawnRequireRaycast(_newPawn)
		_newPawn.onPawnDelete.connect(newSeen.onPawnDelete.bind(_newPawn))
		memory[_newPawn] = newSeen
	
	for thePawn:CharacterPawn in memory:
		var theSeen := memory[thePawn]
		
		#Log.Print("Cone: "+str(Util.roundF(getScoreInConeOfVision(thePawn), 2)))
		
		if(theSeen.seen):
			if(theSeen.seenThisFrame > 0.0):
				theSeen.detection = Util.moveValueTo(theSeen.detection, 1.0, _dt*theSeen.seenThisFrame)
				theSeen.time = 0.0
			else:
				theSeen.detection -= _dt
				if(theSeen.detection <= 0.0):
					theSeen.time += _dt
					if(theSeen.time >= 5.0):
						theSeen.shouldRemove = true
						#Log.Print("FORGOR!")
						break
		else:
			if(theSeen.seenThisFrame > 0.01):
				theSeen.detection += _dt * theSeen.seenThisFrame * PAWN_DETECTION_SPEED
				#Log.Print("DETECTION>: "+str(theSeen.detection))
				if(theSeen.detection >= 1.0):
					#Log.Print("SEEN!")
					theSeen.seen = true # On see
					theSeen.time = 0.0
					seePawns.append(thePawn)
					
					pawn.ai.onSeeNewPawn(thePawn)
			else:
				theSeen.detection -= _dt
				#Log.Print("DETECTION<: "+str(theSeen.detection))
				if(theSeen.detection <= 0.0):
					theSeen.shouldRemove = true
					break
	
	toRem.clear()
	for thePawn:CharacterPawn in memory:
		var theSeen := memory[thePawn]
		if(theSeen.shouldRemove):
			toRem.append(thePawn)
	for toRemovePawn:CharacterPawn in toRem:
		memory.erase(toRemovePawn)
		seePawns.erase(toRemovePawn)
	
# Do we need to use the (slow) raycasts to check if we see this pawn
func doesPawnRequireRaycast(_otherPawn:CharacterPawn) -> bool:
	if(pawn.combatAI.hasEnemy(_otherPawn)):
		return true
	if(pawn.shouldAddEnemyOnSight(_otherPawn) > 0):
		return true
	# True if we're gonna attack on sight
	# True if we're a guard/staffer and the other pawn is off-limits?
	return false

const RAYCAST_MASK_WORLD:int = 3 # world + world(no cam collision)
func getVisionScore(thePawn:CharacterPawn, _seen:MaybeSeenPawn = null) -> float:
	if(thePawn.isLeashedBy(pawn) || pawn.isLeashedBy(thePawn)):
		return 1.0
	
	var _isHostile:bool = _seen.rememberHostile if _seen else doesPawnRequireRaycast(thePawn)
	var theScore:float = getDistanceScore(thePawn)
	if(theScore > 0.01):
		theScore *= getScoreInConeOfVision(thePawn, 100.0 if !_isHostile else 55.0)
	if(theScore > 0.01 && doesPawnRequireRaycast(thePawn)):
		theScore *= getRaycastScore(thePawn)
	return theScore

func getRaycastScore(thePawn:CharacterPawn, _seen:MaybeSeenPawn = null) -> float:
	#if(!doesPawnRequireRaycast(thePawn)):
	#	return 1.0
	var theRay := Util.castRay(pawn.getEyesPosition(), thePawn.getGlobalChestPos()+Vector3(randf_range(-0.3, 0.3), randf_range(-0.5, 0.5), randf_range(-0.3, 0.3)), RAYCAST_MASK_WORLD)
	if(!theRay): # If nothing in the way = we can see
		return 1.0
	return 0.0

const PAWN_VISION_DIST:float = 20.0
const PAWN_VISION_DIST_HOSTILE:float = 40.0
const PAWN_DETECTION_SPEED:float = 3.0

func getCurrentVisionDistance() -> float:
	var theMult:float = (PAWN_BLIND_VISION_MULT if blind else 1.0)
	if(hostile && !blind):
		return PAWN_VISION_DIST_HOSTILE
	return PAWN_VISION_DIST*theMult

const PAWN_BLIND_VISION_MULT:float = 0.1

func getLookAtScoreGeneric(_pos:Vector3, _maxDist:float = PAWN_VISION_DIST, _angMax:float = 60.0) -> float:
	return getDistanceScoreRaw(_pos,_maxDist*(PAWN_BLIND_VISION_MULT if blind else 1.0))*getScoreInConeOfVisionRaw(_pos, _angMax)

func getDistanceScoreRaw(_pos:Vector3, _maxDist:float) -> float:
	var ourPos:Vector3 = pawn.getGlobalPos()
	var theDist:float = ourPos.distance_to(_pos)
	if(theDist >= _maxDist):
		return 0.0
	return remap(theDist, 0.0, _maxDist, 1.0, 0.0)
	
func getDistanceScore(thePawn:CharacterPawn) -> float:
	var ourPos:Vector3 = pawn.getGlobalPos()
	var theirPos:Vector3 = thePawn.getGlobalPos()
	var theDist:float = ourPos.distance_to(theirPos)
	if(theDist >= getCurrentVisionDistance()):
		return 0.0
	return remap(theDist, 0.0, getCurrentVisionDistance(), 1.0, 0.0)

func getScoreInConeOfVisionRaw(_targetPos:Vector3, _maxSpreadDeg:float = 75.0) -> float:
	var ourPos:Vector3 = pawn.getGlobalPos()
	var ourRotY:float = pawn.getYRotationHead()
	var ourForward := Vector3(0,0,-1).rotated(Vector3.UP, ourRotY)
	var cosThreshold := cos(deg_to_rad(_maxSpreadDeg))
	#var distSquared:float = _maxDist*_maxDist
	
	#if(theirPos.distance_squared_to(ourPos) > distSquared):
	#	return false
	var theDir := ourPos - _targetPos
	
	theDir.y *= 0.4
	
	var theDot := ourForward.dot(theDir.normalized())
	if(theDot < cosThreshold): #!isInCone(ourPos, ourRotY, theirPos, _maxSpread)
		return 0.0
	return remap(theDot, cosThreshold, 1.0, 0.0, 1.0)
	
func getScoreInConeOfVision(thePawn:CharacterPawn, _maxSpreadDeg:float = 75.0) -> float:
	return getScoreInConeOfVisionRaw(thePawn.getGlobalPos(), _maxSpreadDeg)

func getSeePawns() -> Array[CharacterPawn]:
	return seePawns

func canSeePawn(_otherPawn:CharacterPawn) -> bool:
	if(!memory.has(_otherPawn)):
		return false
	var theMem:MaybeSeenPawn = memory[_otherPawn]
	return theMem.seen

func makeSeePawn(_newPawn:CharacterPawn):
	if(!memory.has(_newPawn)):
		var newSeen := MaybeSeenPawn.new()
		newSeen.seenThisFrame = 1.0
		newSeen.seen = true
		newSeen.detection = 1.0
		newSeen.vision = weakref(self)
		newSeen.rememberHostile = doesPawnRequireRaycast(_newPawn)
		_newPawn.onPawnDelete.connect(newSeen.onPawnDelete.bind(_newPawn))
		return
	var theMem:MaybeSeenPawn = memory[_newPawn]
	theMem.seenThisFrame = 1.0
	theMem.seen = true
	theMem.detection = 1.0
	theMem.rememberHostile = doesPawnRequireRaycast(_newPawn)
	theMem.time = 0.0

func getDebugString() -> String:
	var strs:Array[String]
	for thePawn:CharacterPawn in memory:
		var theSeen := memory[thePawn]
		strs.append(thePawn.getID()+":d="+str(Util.roundF(theSeen.detection,1))+"t="+str(Util.roundF(theSeen.time,1))+"s="+str("t" if theSeen.seen else "f")+"t="+str(Util.roundF(theSeen.seenThisFrame, 1)))
	return "Mem:"+str(memory.size())+" "+Util.join(strs,",")
