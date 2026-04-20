extends PawnActionBase


func _init() -> void:
	id = "TalkStart"
	alwaysCheckBitfield = CHECK_OTHER | CHECK_OTHER_QUICKACTION
	#subCategory = [C_TALK]

func getVisibleName(_context:PawnActionContext) -> String:
	var theTarget = _context.target
	if(theTarget is CharacterPawn):
		var theChar:BaseCharacter = theTarget.getCharacter()
		if(theChar):
			return theChar.getName()
	
	return "Talk"

func canDoAction(_context:PawnActionContext) -> bool:
	if(!_context.isTargetAPawn()):
		return false
	if(!_context.target.canStartTalkWith(_context.pawn)):
		return false
	return true

func doAction(_context:PawnActionContext) -> bool:
	GM.getInteractionSystem().startInteraction("Talking", {
		main = _context.pawn,
		target = _context.target,
	})
	return true
