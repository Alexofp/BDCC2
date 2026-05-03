extends PawnActionBase

func _init() -> void:
	id = "LeashUnsit"
	alwaysPriority = -12
	alwaysCheckBitfield = CHECK_OTHER

func getVisibleName(_context:PawnActionContext) -> String:
	return "Make get up"

func canDoAction(_context:PawnActionContext) -> bool:
	var theTarget := _context.getTargetPawn()
	if(!theTarget.isLeashedBy(_context.pawn)):
		return false
	if(!theTarget.canGetUpFromPropIfNeedTo()):
		return false
	return true

func doAction(_context:PawnActionContext) -> bool:
	_context.getTargetPawn().getUpFromPropIfNeedToAndCan()
	addHoverText(_context.pawn, "{user.You} {user.youVerb make} {target.you} get up!", _context)
	return true
