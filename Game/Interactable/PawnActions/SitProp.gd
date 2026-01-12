extends PawnActionBase

const ARG_SITSLOT = 0
const ARG_SITNAME = 1

func _init() -> void:
	id = "SitProp"

func getVisibleName(_context:PawnActionContext) -> String:
	var theSlot:String = _context.getArg(ARG_SITSLOT, "")
	var currentSitter:CharacterPawn = _context.target.getSitterSlot(theSlot)
	if(currentSitter == _context.pawn):
		return "Get up"
	return _context.getArg(ARG_SITNAME, "Sit")

func canDoAction(_context:PawnActionContext) -> bool:
	if(!_context.target):
		return false
	var theSlot:String = _context.getArg(ARG_SITSLOT, "")
	var theCurrentSitter:CharacterPawn = _context.target.getSitterSlot(theSlot)
	if(theCurrentSitter && theCurrentSitter != _context.pawn):
		return false
	if(GM.sitManager.isSitting(_context.pawn)):
		if(_context.target.getSitterSlot(theSlot) == _context.pawn):
			pass
		else:
			return false
	
	if(!theCurrentSitter):
		if(!_context.target.canUseSitterSlot(theSlot)):
			return false
	
	return true

func doAction(_context:PawnActionContext) -> bool:
	var theSlot:String = _context.getArg(ARG_SITSLOT, "")
	if(_context.target.getSitterSlot(theSlot) == _context.pawn):
		_context.target.setSitter(theSlot, null)
		return true
	#startDelayedAction("{user.You} BEGAN SITTING!", _context, 2.0, _context.args).setUserMove(ActionSystemEntry.USER_NO_RUNNING)
	_context.target.setSitter(theSlot, _context.pawn)
	return true

func doDelayedAction(_context:PawnActionContext) -> bool:
	var theSlot:String = _context.getArg(ARG_SITSLOT, "")
	if(_context.target.getSitterSlot(theSlot) == _context.pawn):
		#_context.target.setSitter(theSlot, null)
		return true
	_context.target.setSitter(theSlot, _context.pawn)
	return true
