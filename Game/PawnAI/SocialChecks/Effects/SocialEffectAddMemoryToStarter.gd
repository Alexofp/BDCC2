extends SocialCheckBase
class_name SocialEffectAddMemoryToStarter

var memory:String = "" # Added to the target if success >= memorySuccessAbove
var memorySuccessAbove:float = 0.3
var memoryDeny:String = ""

func _init(_mem:String, _successAbove:float = 0.3, _memoryDeny:String = "") -> void:
	memory = _mem
	memorySuccessAbove = _successAbove
	memoryDeny = _memoryDeny

func onEnd(_isDeny:bool):
	if(_isDeny):
		socialHandler.addMemoryStarter(memoryDeny)
	elif(socialHandler.success >= memorySuccessAbove):
		socialHandler.addMemoryStarter(memory)
