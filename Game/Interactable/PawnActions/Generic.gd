extends PawnActionBase

const ARG_ACTION = 0
const ARG_ARGS = 1

func _init() -> void:
	id = "Generic"

func getVisibleName(_context:PawnActionContext) -> String:
	return "GENERIC ACTION"

func canDoAction(_context:PawnActionContext) -> bool:
	if(!_context.target):
		return false
	return true

func doAction(_context:PawnActionContext) -> bool:
	#var theSlot:String = _context.getArg(ARG_SITSLOT, "")
	return true
