extends PawnActionBase

func _init() -> void:
	id = "LeashFreeSelf"
	alwaysPriority = -4
	alwaysCheckBitfield = CHECK_SELF

func getVisibleName(_context:PawnActionContext) -> String:
	return "Free self" # Probably will work differently

func canDoAction(_context:PawnActionContext) -> bool:
	#if(true):
	#	return false

	if(!_context.pawn.isLeashedByAnyone()):
		return false
	#if(_context.pawn.submission.isObeying()):
	#	return false
	return true

func doAction(_context:PawnActionContext) -> bool:
	startDelayedAction("{user.You} {user.youAre} trying to free self!", _context, 5.0, _context.args).setUserMove(ActionSystemEntry.MOVE_NO_MOVEMENT)#.setTimerType(ActionSystemEntry.TIMER_MUST_CONSENT)
	return true

func doDelayedAction(_context:PawnActionContext) -> bool:
	if(!_context.pawn.isLeashedByAnyone()):
		return false
	GM.leashSystem.deleteAllLeashesWithTarget(_context.pawn)
	GM.pawnRegistry.addHoverTextGlobal(_context.pawn, "{user.You} {user.youVerb free|frees} self!", {user=_context.pawn.getCharID(), target=_context.target.getCharID()})
	return true
