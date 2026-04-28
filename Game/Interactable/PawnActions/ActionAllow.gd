extends PawnActionBase

const ARG_UNIQUE_ID = 0
#const ARG_SITNAME = 1

func _init() -> void:
	id = "ActionAllow"
	canDoBitfield = CAN_COLLAPSED | CAN_DEFEATED | CAN_COUPLE_ANIM | CAN_WHILE_DOING_ANY_ACTION | CAN_WHILE_TARGET_OF_ANY_ACTION

func getVisibleName(_context:PawnActionContext) -> String:
	return "Allow action"

func canDoAction(_context:PawnActionContext) -> bool:
	return true

func doAction(_context:PawnActionContext) -> bool:
	var theActionID:int = _context.getArg(ARG_UNIQUE_ID, 0)
	
	var theEntry := GM.actionSystem.findActionEntryByUniqueID(theActionID)
	if(theEntry):
		GM.actionSystem.doTargetAction(theEntry, _context.pawn, id)
		GM.pawnRegistry.addHoverTextGlobal(_context.pawn, "{user.You} {user.youVerb allow} it!", {user=_context.pawn.getCharID()})
	return true
