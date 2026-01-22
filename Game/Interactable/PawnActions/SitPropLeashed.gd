extends PawnActionBase

const ARG_SITSLOT = 0
const ARG_SITNAME = 1
const ARG_TARGETID = 2

func _init() -> void:
	id = "SitPropLeashed"

func getVisibleName(_context:PawnActionContext) -> String:
	var theSlot:String = _context.getArg(ARG_SITSLOT, "")
	var currentSitter:CharacterPawn = _context.target.getSitterSlot(theSlot)
	var targetPawn:CharacterPawn = GM.pawnRegistry.getPawn(_context.getArg(ARG_TARGETID, ""))
	if(!targetPawn):
		return "ERROR!BAD_PAWN"
	
	var targetName:String = targetPawn.getCharacter().getName()
	if(currentSitter == targetPawn):
		return "Make "+targetName+" get up"
	return _context.getArg(ARG_SITNAME, "Sit").replace("$$$", targetName)

func canDoAction(_context:PawnActionContext) -> bool:
	if(!_context.target):
		return false
	var theSlot:String = _context.getArg(ARG_SITSLOT, "")
	var theCurrentSitter:CharacterPawn = _context.target.getSitterSlot(theSlot)
	var targetPawn:CharacterPawn = GM.pawnRegistry.getPawn(_context.getArg(ARG_TARGETID, ""))
	if(!targetPawn):
		return false
	
	if(theCurrentSitter && theCurrentSitter != targetPawn):
		return false
	if(GM.sitManager.isSitting(targetPawn)):
		if(_context.target.getSitterSlot(theSlot) == targetPawn):
			pass
		else:
			return false
	
	if(!theCurrentSitter):
		if(!_context.target.canUseSitterSlot(theSlot)):
			return false
	
	return true

func doAction(_context:PawnActionContext) -> bool:
	var targetPawn:CharacterPawn = GM.pawnRegistry.getPawn(_context.getArg(ARG_TARGETID, ""))
	if(!targetPawn):
		return false
	
	var theSlot:String = _context.getArg(ARG_SITSLOT, "")
	if(_context.target.getSitterSlot(theSlot) == targetPawn):
		_context.target.setSitter(theSlot, null)
		return true
	#startDelayedAction("{user.You} BEGAN SITTING!", _context, 2.0, _context.args).setUserMove(ActionSystemEntry.USER_NO_RUNNING)
	_context.target.setSitter(theSlot, targetPawn)
	return true

func doDelayedAction(_context:PawnActionContext) -> bool:
	var targetPawn:CharacterPawn = GM.pawnRegistry.getPawn(_context.getArg(ARG_TARGETID, ""))
	if(!targetPawn):
		return false
	
	var theSlot:String = _context.getArg(ARG_SITSLOT, "")
	if(_context.target.getSitterSlot(theSlot) == targetPawn):
		#_context.target.setSitter(theSlot, null)
		return true
	_context.target.setSitter(theSlot, targetPawn)
	return true
