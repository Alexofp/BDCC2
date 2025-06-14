extends AIActionBase

var target:Vector3 = Vector3(0.0, 0.0, 0.0)

func _init() -> void:
	id = "GoTo"

func start(_args:Array):
	if(_args.is_empty()):
		failAction()
		return
	target = _args[0]
	goTowards(target)

func processAction(_dt:float):
	if(getDistSquaredTo(target) < 10.0 && getAI().getNavAgent().is_navigation_finished()):
		completeAction()

func processRare():
	goTowards(target)
	#if(RNG.chance(20)):
	#	startChildAction("Wait")
