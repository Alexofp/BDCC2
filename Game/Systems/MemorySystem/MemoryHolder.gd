extends RefCounted
class_name MemoryHolder

var charRef:WeakRef
var memories:Array[MemoryEntry]
var closestToExpire:Array[MemoryEntry]

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
	sortClosestEvents()
	Log.Print("New memory was added to "+getChar().getID()+": "+_memory.memory.id)

func removeMemoryEntry(_memory:MemoryEntry):
	memories.erase(_memory)
	closestToExpire.erase(_memory)
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
