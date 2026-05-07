extends SocialEffectBase
class_name SocialEffectAddMemoryTarget

var memory:String = "" # Added to the target if success >= memorySuccessAbove
var memorySuccessAbove:float = 0.3

func _init(_mem:String, _successAbove:float = 0.3) -> void:
	memory = _mem
	memorySuccessAbove = _successAbove

func doEffect(_isDeny:bool):
	if(_isDeny || socialHandler.success >= memorySuccessAbove):
		socialHandler.addMemoryTarget(memory)
