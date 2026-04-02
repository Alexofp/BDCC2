extends RefCounted
class_name MemoryBase

const TIME_MINUTE := 60
const TIME_HOUR := 3600
const TIME_DAY := 24*TIME_HOUR

var id:String = ""

var duration:int = 60 # How long is this memory remembered (can affect dialogues)
var durationEffects:int = -1 # How long does this memory affect the mood. if < 0, then the duration is used

var stackMult:float = 0.8
var stackMax:int = 99 # All of the memories are remembered but only stackMax amount of them will affect mood
var priority:float = 1.0 # Used for AskDay social interaction. Memories with higher priority will be first

var mood:float = 0.0 # sad or happy
var anger:float = 0.0 # kind or angry
var lust:float = 0.0 # chaste or horny
#var helpful:float = 0.0 # demanding or helpful

func getName() -> String:
	return "Some memory"
	
func getDescription() -> String:
	return "Something happened."

func processEffects(_effects:MemoryEffects):
	#_effects.addMood(0.1)
	pass
