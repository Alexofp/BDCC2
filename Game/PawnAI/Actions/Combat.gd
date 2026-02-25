extends AIActionBase

func _init() -> void:
	id = "Combat"

func start(_args:Array):
	#if(_args.is_empty()):
	#	failAction()
	#	return
	pass

func onEnd():
	#stopWalking()
	pass

func processAction(_dt:float):
	getPawn().combatAI.processAI(_dt)

func think():
	var thePawn := getPawn()
	if(!thePawn.combatAI.hasEnemies()):
		completeAction()
	pass

func getDebugText() -> String:
	return "nya"

func shouldBeInCombatMode() -> bool:
	return true
