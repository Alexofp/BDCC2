extends PawnActionBase

func _init() -> void:
	id = "Dominate"
	alwaysCheckBitfield = CHECK_OTHER | CHECK_OTHER_QUICKACTION
	#alwaysCheckBitfield = CHECK_OTHER
	#subCategory = [C_TALK]

func getVisibleName(_context:PawnActionContext) -> String:
	var theTarget = _context.target
	if(theTarget is CharacterPawn):
		var theChar:BaseCharacter = theTarget.getCharacter()
		if(theChar):
			return "Dominate "+theChar.getName()
	
	return "Dominate"

func canDoAction(_context:PawnActionContext) -> bool:
	#if(true): # Disabled
	#	return false
	if(!_context.isTargetAPawn()):
		return false
	var theTargetPawn:CharacterPawn = _context.target
	if(!theTargetPawn.submission.canBeEasilyDominatedBy(_context.pawn)):
		return false
	if(_context.pawn.hasInteraction() || _context.pawn.isDoingSomething()):
		return false
	if(_context.target.hasInteraction()):
		return false
	return true

func doAction(_context:PawnActionContext) -> bool:
	var theTargetPawn:CharacterPawn = _context.target
	if(!theTargetPawn.submission.tryMakeObeyPawn(_context.pawn)):
		return false
	GM.main.interactionSystem.startInteraction("Dominated", {
		main = _context.pawn,
		target = _context.target,
	})
	return true
