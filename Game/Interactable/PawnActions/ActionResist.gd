extends PawnActionBase

const ARG_UNIQUE_ID = 0
#const ARG_SITNAME = 1

func _init() -> void:
	id = "ActionResist"
	checkDoingAnyActions = false
	checkIsTargetOfAnyAciton = false
	canDoWhileCollapsed = true
	canDoWhileDefeated = true

func getVisibleName(_context:PawnActionContext) -> String:
	return "Resist action"

func canDoAction(_context:PawnActionContext) -> bool:
	var theActionID:int = _context.getArg(ARG_UNIQUE_ID, 0)
	var theEntry := GM.actionSystem.findActionEntryByUniqueID(theActionID)
	
	if(theEntry):
		var theTargetEntry := theEntry.getTargetSpecific(_context.pawn)
		if(theTargetEntry):
			if(theTargetEntry.timerType == ActionSystemEntry.TIMER_CAN_DENY):
				if(_context.pawn.isCollapsed() || _context.pawn.isDefeated()):
					return false
	
	return true

func doAction(_context:PawnActionContext) -> bool:
	var theActionID:int = _context.getArg(ARG_UNIQUE_ID, 0)
	
	var theEntry := GM.actionSystem.findActionEntryByUniqueID(theActionID)
	if(theEntry):
		GM.actionSystem.resistAction(theEntry, _context.pawn)
		_context.pawn.addHoverText(GM.textParser.parseStringDefault("*{user.You} {user.youVerb resist}*", {user=_context.pawn.getCharID()}).text)
	
	return true
