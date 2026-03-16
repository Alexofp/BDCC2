extends PawnActionBase


func _init() -> void:
	id = "TalkTest"
	alwaysCheckedOtherPawn = true
	alwaysCheckedOtherPawnQuickAction = true
	subCategory = [C_TALK]

func getVisibleName(_context:PawnActionContext) -> String:
	return "TALK"

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
	GM.getInteractionSystem().startInteraction("Talking", {
		main = _context.pawn,
		target = _context.target,
	})
	return true
