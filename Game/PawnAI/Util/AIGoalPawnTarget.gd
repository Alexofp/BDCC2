extends AIGoalDynamic
class_name AIGoalPawnTarget

## Dynamic AI goal that targets another pawn

var targetID:String

func saveData() -> Dictionary:
	var _data:Dictionary = super.saveData()
	_data["tid"] = targetID
	return _data

func loadData(_data:Dictionary):
	super.loadData(_data)
	targetID = SAVE.loadStr(_data, "tid")

func isSameAs(_otherGoal:AIGoalBase) -> bool:
	if(!super.isSameAs(_otherGoal)):
		return false
	if(id != _otherGoal.id):
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
