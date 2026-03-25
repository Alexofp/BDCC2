extends PawnActionBase

func _init() -> void:
	id = "DefeatedHelpGetUp"
	alwaysCheckBitfield = CHECK_OTHER | CHECK_OTHER_QUICKACTION

func getVisibleName(_context:PawnActionContext) -> String:
	return "Help to get up"

func canDoAction(_context:PawnActionContext) -> bool:
	if(!_context.target.canBeHelpedToRecoverFromDefeat(_context.pawn)):
		return false
	return true

func doAction(_context:PawnActionContext) -> bool:
	#_context.pawn.recoverFromDefeat()
	startDelayedAction("{user.You} {user.youVerb try|tries} to help {target.you} to get up.", _context, 1.0, _context.args).setCancelType(ActionSystemEntry.CANCEL_ALLOW)
	return true

func doDelayedAction(_context:PawnActionContext) -> bool:
	_context.target.recoverFromDefeat()
	_context.pawn.getCharacter().charState.setPain(0.0)
	return true
