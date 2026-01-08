extends PawnActionBase

func _init() -> void:
	id = "StartSex"
	alwaysCheckedOtherPawn = true
	alwaysCheckedOtherPawnQuickAction = true

func getVisibleName(_context:PawnActionContext) -> String:
	return "Start sex"

func canDoAction(_context:PawnActionContext) -> bool:
	if(!_context.isTargetAPawn()):
		return false
	if(GM.sitManager.isSitting(_context.pawn)):
		return false
	if(GM.sitManager.isSitting(_context.getTargetPawn())):
		return false
	return true

func doAction(_context:PawnActionContext) -> bool:
	#GM.sexManager.askStartMasturbation(_context.pawn.getCharID())
	
	var newSex := SexStartConf.new()
	newSex.sexType = SexType.OnTheFloor
	newSex.addRole("dom", _context.pawn.getCharID(), SexRole.Dom)
	newSex.addRole("sub", _context.target.getCharID(), SexRole.Sub)
	newSex.pos = _context.pawn.global_position
	newSex.ang = _context.pawn.global_rotation
	GM.sexManager.startSex(newSex)
	
	return true
