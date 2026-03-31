extends Node
class_name MemorySystem

var rareUpdateTimer:float = 0.0

func _physics_process(_delta: float) -> void:
	rareUpdateTimer += _delta
	if(rareUpdateTimer > 1.27):
		processRare(rareUpdateTimer)
		rareUpdateTimer = 0.0

func processRare(_dt:float):
	var currentTime := GM.main.timeManager.getTimeFull()
	
	for charID in GM.main.characterRegistry.characters:
		var theCharacter:BaseCharacter = GM.main.characterRegistry.characters[charID]
		
		theCharacter.memoryHolder.processRare(_dt, currentTime)

func addMemory(_targetCharID:String, _memoryID:String, _otherCharID:String = ""):
	if(!GlobalRegistry.hasMemory(_memoryID)):
		return
	var theCharacter := GM.main.characterRegistry.getCharacter(_targetCharID)
	if(!theCharacter):
		return
	theCharacter.memoryHolder.addMemory(_memoryID, _otherCharID)

func addMemoryOrError(_targetCharID:String, _memoryID:String, _otherCharID:String = ""):
	if(!GlobalRegistry.hasMemory(_memoryID)):
		assert(false, "No memory found: "+str(_memoryID))
		return
	var theCharacter := GM.main.characterRegistry.getCharacter(_targetCharID)
	if(!theCharacter):
		return
	theCharacter.memoryHolder.addMemory(_memoryID, _otherCharID)
