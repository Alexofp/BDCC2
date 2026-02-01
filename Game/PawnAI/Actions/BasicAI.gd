extends AIActionBase

func _init() -> void:
	id = "BasicAI"

func start(_args:Array):
	pass

func processAction(_dt:float):
	pass

func think():
	if(isLeashed()):
		stopSubAction()
		return
	
	if(hasSubAction()):
		return
	
	var possible:Array[String] = [
		"Wander",
	]
	
	if(!isSitting()):
		possible.append("SitAndChill")
	
	startSubActionUnlessSameTag(RNG.pick(possible))
