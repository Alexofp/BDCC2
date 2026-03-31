extends RefCounted
class_name MemorySimpleBank

const F_NAME := 0
const F_DESC := 1
const F_STACKMULT := 2
const F_STACKMAX := 3
const F_PRIORITY := 4
const F_DURATION := 5
const F_DURATION_EFFECTS := 6

# Mood alters
const F_MOOD := 10
const F_ANGER := 11
const F_LUST := 12
#const F_HELPFUL := 13

var memories:Dictionary[String, Dictionary]

func createMemories() -> Array[MemorySimple]:
	var result:Array[MemorySimple] = []
	
	for memoryID in memories:
		var theEntry:Dictionary = memories[memoryID]
		
		var newMemory := MemorySimple.new()
		newMemory.id = memoryID
		newMemory.name = getString(theEntry, F_NAME, newMemory.name)
		newMemory.desc = getString(theEntry, F_DESC, newMemory.desc)
		newMemory.stackMult = getFloat(theEntry, F_STACKMULT, newMemory.stackMult)
		newMemory.stackMax = getInt(theEntry, F_STACKMAX, newMemory.stackMax)
		newMemory.priority = getFloat(theEntry, F_PRIORITY, newMemory.priority)
		newMemory.duration = getInt(theEntry, F_DURATION, newMemory.duration)
		newMemory.durationEffects = getInt(theEntry, F_DURATION_EFFECTS, newMemory.durationEffects)
		
		newMemory.mood = getFloat(theEntry, F_MOOD, newMemory.mood)
		newMemory.anger = getFloat(theEntry, F_ANGER, newMemory.anger)
		newMemory.lust = getFloat(theEntry, F_LUST, newMemory.lust)
		
		result.append(newMemory)
	
	return result

func getFloat(_entry:Dictionary, _name:int, _default:float = 0.0) -> float:
	if(!_entry.has(_name)):
		return _default
	return _entry[_name]

func getString(_entry:Dictionary, _name:int, _default:String = "") -> String:
	if(!_entry.has(_name)):
		return _default
	return _entry[_name]

func getInt(_entry:Dictionary, _name:int, _default:int = 0) -> int:
	if(!_entry.has(_name)):
		return _default
	return _entry[_name]
