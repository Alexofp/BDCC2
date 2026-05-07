extends SocialEffectAddMemoryTarget
class_name SocialEffectAddMemoryStarter

func doEffect(_isDeny:bool):
	if(_isDeny || socialHandler.success >= memorySuccessAbove):
		socialHandler.addMemoryStarter(memory)
