extends SocialCheckBase
class_name SocialEffectAddMemory

var memory:String = "" # Added to the target if success >= memorySuccessAbove
var memorySuccessAbove:float = 0.3
var memoryDeny:String = ""

func _init(_mem:String, _successAbove:float = 0.3, _memoryDeny:String = "") -> void:
	memory = _mem
	memorySuccessAbove = _successAbove
	memoryDeny = _memoryDeny

func onEnd(_status:int):
	if(_status == SocialInteractionHandler.STATUS_DENY):
		socialHandler.addMemoryTarget(memoryDeny)
	elif(_status == SocialInteractionHandler.STATUS_AGREE && socialHandler.success >= memorySuccessAbove):
		socialHandler.addMemoryTarget(memory)
