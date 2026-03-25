extends PawnActionBase

func _init() -> void:
	id = "TalkTest2"
	alwaysCheckBitfield = CHECK_OTHER | CHECK_OTHER_QUICKACTION
	subCategory = [C_TALK]

func getVisibleName(_context:PawnActionContext) -> String:
	return "DO TEST"

func canDoAction(_context:PawnActionContext) -> bool:
	if(!_context.isTargetAPawn()):
		return false
	if(_context.pawn.hasInteraction()):
		return false
	if(_context.target.hasInteraction()):
		return false
	#if(GM.sitManager.isSitting(_context.pawn)):
	#	return false
	#if(GM.sitManager.isSitting(_context.getTargetPawn())):
	#	return false
	return true

func doAction(_context:PawnActionContext) -> bool:
	var thePawn:CharacterPawn = _context.target
	#thePawn.ai.goalHandler.addGoal("StartFriendlyFight", [_context.pawn])
	GM.main.coupleAnimsSystem.start("Hug", _context.pawn, thePawn)
	return true
