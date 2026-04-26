extends PawnActionBase

func _init() -> void:
	id = "Submit"
	alwaysCheckBitfield = CHECK_SELF
	#subCategory = ["Test", "Test2"]

func getVisibleName(_context:PawnActionContext) -> String:
	return "Submit"

func canDoAction(_context:PawnActionContext) -> bool:
	#if(GM.sitManager.isSitting(_context.pawn)):
	#	return false
	if(!_context.pawn.canBeDefeated()):
		return false
	return true

func doAction(_context:PawnActionContext) -> bool:
	#var theInfo := Network.getPlayerInfoControllingCharID(_context.pawn.getCharID())
	#if(theInfo):
	#	theInfo.charID = ""
	#GM.sexManager.askStartMasturbation(_context.pawn.getCharID())
	#startDelayedAction(_context, 2.0)
	_context.pawn.makeDefeated()
	return true

#func doDelayedAction(_context:PawnActionContext) -> bool:
	#GM.sexManager.askStartMasturbation(_context.pawn.getCharID())
	#return true
