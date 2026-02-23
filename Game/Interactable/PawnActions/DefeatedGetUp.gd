extends PawnActionBase

func _init() -> void:
	id = "DefeatedGetUp"
	alwaysCheckedSelf = true
	alwaysCheckedSelfQuickAction = true
	canDoWhileDefeated = true

func getVisibleName(_context:PawnActionContext) -> String:
	return "Get up"

func canDoAction(_context:PawnActionContext) -> bool:
	if(!_context.pawn.canRecoverFromDefeat()):
		return false
	return true

func doAction(_context:PawnActionContext) -> bool:
	#_context.pawn.recoverFromDefeat()
	startDelayedAction("{user.You} {user.youVerb try|tries} to get up.", _context, 2.0, _context.args).setCancelType(ActionSystemEntry.CANCEL_ALLOW)
	return true

func doDelayedAction(_context:PawnActionContext) -> bool:
	_context.pawn.recoverFromDefeat()
	return true
