extends RefCounted
class_name MemoryHolder

var charRef:WeakRef
var memories:Array[MemoryEntry] # newest memories are last
var closestToExpire:Array[MemoryEntry]
var memoryByType:Dictionary[String, Array]

var moodValues:MoodValues = MoodValues.new()

func setCharacter(_character:BaseCharacter):
	charRef = weakref(_character)

func getChar() -> BaseCharacter:
	return charRef.get_ref()

func getCharacter() -> BaseCharacter:
	return charRef.get_ref()

func getPawn() -> CharacterPawn:
	return GM.main.pawn_registry.getPawn(getChar().getID())

func addMemory(_memoryID:String, _otherCharID:String = ""):
	var theMemory := GlobalRegistry.getMemory(_memoryID)
	if(!theMemory):
		return
	#var theAm:int = theMemory.stackMax
	
	var currentTime := GM.main.timeManager.getTimeFull()
	var newEntry := MemoryEntry.new()
	newEntry.memory = theMemory
	newEntry.happenedAt = currentTime
	newEntry.willExpireAt = TimeManager.advanceFullTime(currentTime, theMemory.duration)
	newEntry.noEffectsAfter = TimeManager.advanceFullTime(currentTime, theMemory.durationEffects) if theMemory.durationEffects >= 0 else newEntry.willExpireAt
	newEntry.otherPawnID = _otherCharID
	pushMemoryEntry(newEntry)
	
func pushMemoryEntry(_memory:MemoryEntry):
	if(!_memory):
		return
	memories.append(_memory)
	closestToExpire.append(_memory)
	if(!memoryByType.has(_memory.memory.id)):
		var Ar:Array[MemoryEntry] = [_memory]
		memoryByType[_memory.memory.id] = Ar
	else:
		memoryByType[_memory.memory.id].append(_memory)
	sortClosestEvents()
	Log.Print("New memory was added to "+getChar().getID()+": "+_memory.memory.id)

func removeMemoryEntry(_memory:MemoryEntry):
	memories.erase(_memory)
	closestToExpire.erase(_memory)
	if(memoryByType.has(_memory.memory.id)):
		memoryByType[_memory.memory.id].erase(_memory)
		if(memoryByType[_memory.memory.id].is_empty()):
			memoryByType.erase(_memory.memory.id)
	Log.Print("Memory removed from "+getChar().getID()+": "+_memory.memory.id)

func sortClosestEvents():
	closestToExpire.sort_custom(func(_a:MemoryEntry, _b:MemoryEntry): return _a.willExpireAt < _b.willExpireAt)

func processRare(_dt:float, _fullTime:int):
	if(closestToExpire.is_empty()):
		return
	while(!closestToExpire.is_empty()):
		var theClosestsEvent:MemoryEntry = closestToExpire.front()
		if(_fullTime >= theClosestsEvent.willExpireAt):
			removeMemoryEntry(theClosestsEvent)
		else:
			break
	
	calculateMoodValues()

func calculateMoodValues():
	var theCurrentTime := GM.main.timeManager.getTimeFull()
	#var newEffects:MemoryEffects = MemoryEffects.new()
	moodValues.clear()
	var memoryMults:Dictionary[MemoryBase, float]
	var memoryAm:Dictionary[MemoryBase, int]
	
	var memAm:int = memories.size()
	for _i in memAm:
		var _indx:int = memAm - _i - 1
		var theMemoryEntry := memories[_indx]
		if(theCurrentTime > theMemoryEntry.noEffectsAfter || !theMemoryEntry.memory.mood):
			continue
		var theMemory := theMemoryEntry.memory
		if(memoryAm.get(theMemory, 0) >= theMemory.stackMax):
			continue
		
		var secondsPassed:int = theCurrentTime - theMemoryEntry.happenedAt
		var totalDuration:int = theMemoryEntry.noEffectsAfter - theMemoryEntry.happenedAt
		var theProgress:float = remap(float(secondsPassed), 0.0, float(totalDuration), 0.0, 1.0)
		
		var theMult:float = (1.0 - theProgress)
		if(!memoryMults.has(theMemory)):
			memoryMults[theMemory] = 1.0
			memoryAm[theMemory] = 1
		else:
			memoryMults[theMemory] *= theMemory.stackMult
			theMult *= memoryMults[theMemory]
			memoryAm[theMemory] += 1
	
		#print(theMult)
		moodValues.combineWith(theMemory.mood, theMult)
		
	#return newEffects

func getMemoryAmount(_memoryID:String) -> int:
	if(!memoryByType.has(_memoryID)):
		return 0
	return memoryByType[_memoryID].size()
	
func getMemoryAmountWith(_memoryID:String, _otherCharID:String) -> int:
	if(!memoryByType.has(_memoryID)):
		return 0
	var theResult:int = 0
	var theMemories:Array[MemoryEntry] = memoryByType[_memoryID]
	for theMemoryEntry in theMemories:
		if(theMemoryEntry.otherPawnID == _otherCharID):
			theResult += 1
	return theResult

func hasMemoryID(_memoryID:String) -> bool:
	if(!memoryByType.has(_memoryID)):
		return false
	return true

func hasMemoryWith(_memoryID:String, _otherCharID:String) -> bool:
	if(!memoryByType.has(_memoryID)):
		return false
	var theMemories:Array[MemoryEntry] = memoryByType[_memoryID]
	for theMemoryEntry in theMemories:
		if(theMemoryEntry.otherPawnID == _otherCharID):
			return true
	return false

func hasMemoryButNotWith(_memoryID:String, _otherCharID:String) -> bool:
	if(!memoryByType.has(_memoryID)):
		return false
	var theMemories:Array[MemoryEntry] = memoryByType[_memoryID]
	for theMemoryEntry in theMemories:
		if(theMemoryEntry.otherPawnID == _otherCharID):
			return false
	return true

func getDebugLines() -> Array[String]:
	return [
		#"M:"+str(Util.roundF(memoryEffects.mood,2))+",A:"+str(Util.roundF(memoryEffects.anger,2))+",L:"+str(Util.roundF(memoryEffects.lust,2))
	]

func doReactionFunctionCall(_runner:ReactionSystemRunner, _method:String, _args:Array):
	if(_method == "has"):
		if(_args.size() == 1):
			return hasMemoryID(_args[0])
		return hasMemoryWith(_args[0], _args[1].getID())
	if(_method == "amountOf"):
		if(_args.size() == 1):
			return getMemoryAmount(_args[0])
		return getMemoryAmountWith(_args[0], _args[1].getID())
	
	return null

func getAskDayReactions(_askingPawn:CharacterPawn, _maxAmount:int = 3) -> Array[ReactionSystem.ReactionResult]:
	if(_maxAmount <= 0):
		return []
	var result:Array[ReactionSystem.ReactionResult]
	
	var possible:Array
	for theEntry in memories:
		var thePrio := theEntry.calculateFinalPriority()
		if(thePrio <= 0.0):
			continue
		possible.append([theEntry, thePrio])
	
	var addedMemoriesTypes:Dictionary[MemoryBase, bool]
	
	var theContext := ReactionSystem.ReactionContext.new()
	theContext.main = getPawn().getCharacter()
	theContext.args = {}
	
	while(!possible.is_empty()):
		var theEntry:MemoryEntry = RNG.grabWeightedPairs(possible)
		if(addedMemoriesTypes.has(theEntry.memory)):
			continue
		
		if(theEntry.otherPawnID.is_empty()):
			theContext.target = null
		else:
			theContext.target = GM.characterRegistry.getCharacter(theEntry.otherPawnID)
			if(!theContext.target):
				continue
		theContext.args = {
			memorySeconds = theEntry.getElapsedSeconds(),
			memoryDays = theEntry.getElapsedDays(),
		} # Add the time value here or something
		
		var reactionID:String = "Memory_"+str(theEntry.memory.id)
		var theReaction := GM.main.reactionSystem.generateReaction(reactionID, theContext)
		if(!theReaction):
			continue
		
		result.append(theReaction)
		if(result.size() >= _maxAmount):
			return result
		addedMemoriesTypes[theEntry.memory] = true
		
	return result

#func say(_roleSay:int, _reaction:String, _roleTarget:int = -1, _args:Dictionary[String, Variant] = {}):
	#var thePawn := getPawn(_roleSay)
	#if(!thePawn):
		#return
	#var theContext := ReactionSystem.ReactionContext.new()
	#theContext.main = thePawn.getCharacter()
	#theContext.target = getPawn(_roleTarget).getCharacter() if _roleTarget >= 0 else null
	#theContext.args = _args
	#var theReaction := GM.main.reactionSystem.generateReaction(_reaction, theContext)
	#if(!theReaction):
		#Log.Printerr("# WRITE ME: "+_reaction+" #")
		#sayText(_roleSay, "#WRITE_ME: "+_reaction+"#", true)
		#return
	#sayText(_roleSay, theReaction.line, true)
