extends RefCounted
class_name AIActionBase

var id:String = ""

var ai:PawnAI

var childAction:AIActionBase

var hasCompleted:bool = false
var hasFailed:bool = false

func start(_args:Array):
	pass

func processAction(_dt:float):
	pass

func processActionFinal(_dt:float):
	if(childAction):
		childAction.processAction(_dt)
	else:
		processAction(_dt)
	checkChildAction()

func processRare():
	pass

func processRareFinal():
	if(childAction):
		childAction.processRare()
	else:
		processRare()
	checkChildAction()

func startChildAction(_id:String, _args:Array = []):
	var theAction:AIActionBase = GlobalRegistry.createAIAction(_id)
	if(!theAction):
		assert(false, "No ai action found: "+str(_id))
		return
	childAction = theAction
	childAction.setAI(getAI())
	childAction.start(_args)

func setAI(_ai:PawnAI):
	ai = _ai

func getAI() -> PawnAI:
	return ai

func getPawn() -> CharacterPawn:
	if(!ai):
		return null
	return ai.getPawn()

func completeAction():
	hasCompleted = true

func failAction():
	hasFailed = false

func hasEnded() -> bool:
	return hasCompleted || hasFailed

func hasChildAction() -> bool:
	return childAction != null

func checkChildAction():
	if(!childAction):
		return
	if(!childAction.hasEnded()):
		return
	childAction = null
	#TODO: Some callback? Getting a result?

func goTowards(_pos:Vector3, _run:bool = false):
	ai.goTowards(_pos, _run)

func stopWalking():
	ai.stopWalking()

func getDistSquaredTo(_pos:Vector3) -> float:
	return getPawn().global_position.distance_squared_to(_pos)
