extends PawnActionBase

const ARG_UNIQUE_ID = 0
#const ARG_SITNAME = 1

func _init() -> void:
	id = "ActionAllow"
	checkDoingAnyActions = false
	checkIsTargetOfAnyAciton = false
	canDoWhileCollapsed = true
	canDoWhileDefeated = true

func getVisibleName(_context:PawnActionContext) -> String:
	return "Allow action"

func canDoAction(_context:PawnActionContext) -> bool:
	return true

func doAction(_context:PawnActionContext) -> bool:
	var theActionID:int = _context.getArg(ARG_UNIQUE_ID, 0)
	
	var theEntry := GM.actionSystem.findActionEntryByUniqueID(theActionID)
	if(theEntry):
		GM.actionSystem.allowAction(theEntry, _context.pawn)
		GM.pawnRegistry.addHoverTextGlobal(_context.pawn, "{user.You} {user.youVerb allow} it!", {user=_context.pawn.getCharID()})
	return true
