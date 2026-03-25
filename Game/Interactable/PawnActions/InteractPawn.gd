extends PawnActionBase

const ARG_NAME = 0

func _init() -> void:
	id = "InteractPawn"
	alwaysCheckBitfield = CHECK_OTHER_QUICKACTION

func getVisibleName(_context:PawnActionContext) -> String:
	var theTarget = _context.target
	if(theTarget is CharacterPawn):
		var theChar:BaseCharacter = theTarget.getCharacter()
		if(theChar):
			return theChar.getName()
	
	return _context.getArg(ARG_NAME, "Interact")

func canDoAction(_context:PawnActionContext) -> bool:
	if(!_context.target):
		return false
	return true

func doAction(_context:PawnActionContext) -> bool:
	GI.makePawnOpenInteractMenuSpecific(_context.pawn, _context.target)
	#GM.main.showInteractMenuSpecific(_context.target)
	return true
