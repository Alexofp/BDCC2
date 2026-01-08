extends PawnActionBase

func _init() -> void:
	id = "Masturbate"
	alwaysCheckedSelf = true

func getVisibleName(_context:PawnActionContext) -> String:
	return "Masturbate"

func canDoAction(_context:PawnActionContext) -> bool:
	if(GM.sitManager.isSitting(_context.pawn)):
		return false
	return true

func doAction(_context:PawnActionContext) -> bool:
	GM.sexManager.askStartMasturbation(_context.pawn.getCharID())
	return true
