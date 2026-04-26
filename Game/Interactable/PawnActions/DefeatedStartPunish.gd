extends PawnActionBase

func _init() -> void:
	id = "DefeatedStartPunish"
	#alwaysCheckBitfield = CHECK_OTHER | CHECK_OTHER_QUICKACTION

func getVisibleName(_context:PawnActionContext) -> String:
	return "Punish"

func canDoAction(_context:PawnActionContext) -> bool:
	#if(!_context.target.canBeHelpedToRecoverFromDefeat(_context.pawn)):
	#	return false
	if(!_context.getTargetPawn().isDefeated()):
		return false
	return true

func doAction(_context:PawnActionContext) -> bool:
	GM.getInteractionSystem().startInteraction("DominateDefeated", {
		main = _context.pawn,
		target = _context.target,
	})
	#_context.pawn.recoverFromDefeat()
	#startDelayedAction("{user.You} {user.youVerb try|tries} to help {target.you} to get up.", _context, 1.0, _context.args).setCancelType(ActionSystemEntry.CANCEL_ALLOW)
	return true
