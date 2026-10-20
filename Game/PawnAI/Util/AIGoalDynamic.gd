extends AIGoalBase
class_name AIGoalDynamic

## Dynamic goal that can be added and removed at any time

var elapsedTime:float = 0.0
var goalTimeout:float = 30.0

func saveData() -> Dictionary:
	var _data:Dictionary = super.saveData()
	_data["et"] = elapsedTime
	return _data

func loadData(_data:Dictionary):
	super.loadData(_data)
	elapsedTime = SAVE.loadFloat(_data, "et")

func processRareFinal(_dt:float):
	elapsedTime += _dt
	if(goalTimeout > 0.0 && elapsedTime >= goalTimeout):
		stopMe()
		return
	if(isImpossible()):
		stopMe()
		return
	
	super.processRareFinal(_dt)

func isSameAs(_otherGoal:AIGoalBase) -> bool:
	if(id != _otherGoal.id):
		return false
	
	return true
