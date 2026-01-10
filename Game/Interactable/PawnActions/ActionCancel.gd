extends PawnActionBase

const ARG_UNIQUE_ID = 0
#const ARG_SITNAME = 1

func _init() -> void:
	id = "ActionCancel"
	checkDoingAnyActions = false
	checkIsTargetOfAnyAciton = false

func getVisibleName(_context:PawnActionContext) -> String:
	return "Cancel action"

func canDoAction(_context:PawnActionContext) -> bool:
	return true

func doAction(_context:PawnActionContext) -> bool:
	var theActionID:int = _context.getArg(ARG_UNIQUE_ID, 0)
	
	var theEntry := GM.actionSystem.findActionEntryByUniqueID(theActionID)
	if(theEntry):
		GM.actionSystem.cancelAction(theEntry)
	
	return true
