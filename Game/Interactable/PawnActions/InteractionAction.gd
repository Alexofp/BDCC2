extends PawnActionBase

const ARG_NAME = 0
const ARG_INDEX = 1
const ARG_ACTIONID = 2

func _init() -> void:
	id = "InteractionAction"
	
	canDoBitfield = CAN_COLLAPSED | CAN_DEFEATED

func getVisibleName(_context:PawnActionContext) -> String:
	return _context.getArg(ARG_NAME, "ERROR?")

func canDoAction(_context:PawnActionContext) -> bool:
	return true

func doAction(_context:PawnActionContext) -> bool:
	var theInteraction := _context.pawn.getInteraction()
	if(!theInteraction):
		return false
	
	var _indx:int = _context.getArg(ARG_INDEX, 0)
	var _actionID:String = _context.getArg(ARG_ACTIONID, "")
	var theActions := theInteraction.getActionsFor(_context.pawn)
	
	if(_indx < 0 || _indx >= theActions.size() || theActions[_indx].id != _actionID):
		return false
	
	theInteraction.doActionFor(_context.pawn, theActions[_indx])
	return true
