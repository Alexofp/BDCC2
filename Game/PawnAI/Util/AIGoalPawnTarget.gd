extends AIGoalDynamic
class_name AIGoalPawnTarget

## Dynamic AI goal that targets another pawn

var targetID:String

func isSameAs(_otherGoal:AIGoalBase) -> bool:
	if(!super.isSameAs(_otherGoal)):
		return false
	if(targetID != _otherGoal.targetID):
		return false
	return true

func setArgs(_args:Array):
	var theTarget = _args[0]
	if(theTarget is String):
		targetID = theTarget
	elif(theTarget is CharacterPawn):
		targetID = theTarget.getCharID()
	else:
		assert(false, "BAD TARGET")

func start():
	pass

func isImpossible() -> bool:
	if(!getTarget()):
		return true
	return false

func getTarget() -> CharacterPawn:
	return GM.main.pawn_registry.getPawn(targetID)
