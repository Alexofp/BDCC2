extends PawnActionBase

func _init() -> void:
	id = "SwitchTo"
	alwaysCheckedOtherPawn = true
	alwaysPriority = -10

func getVisibleName(_context:PawnActionContext) -> String:
	return "Switch to"

func canDoAction(_context:PawnActionContext) -> bool:
	if(!_context.isTargetAPawn()):
		return false
	var curInfo := Network.getPlayerInfoControllingCharID(_context.target.getCharID())
	if(curInfo):
		return false
	return true

func doAction(_context:PawnActionContext) -> bool:
	if(!_context.isTargetAPawn()):
		return false
	var myInfo := Network.getPlayerInfoControllingCharID(_context.pawn.getCharID())
	if(!myInfo):
		return false
	
	var curInfo := Network.getPlayerInfoControllingCharID(_context.target.getCharID())
	if(!curInfo):
		myInfo.charID = _context.target.getCharID()
	
	return true
