extends PawnActionBase

const ARG_NAME = 0

func _init() -> void:
	id = "Interact"

func getVisibleName(_context:PawnActionContext) -> String:
	return _context.getArg(ARG_NAME, "Interact")

func canDoAction(_context:PawnActionContext) -> bool:
	if(!_context.target):
		return false
	return true

func doAction(_context:PawnActionContext) -> bool:
	GI.makePawnOpenInteractMenuSpecific(_context.pawn, _context.target)
	#GM.main.showInteractMenuSpecific(_context.target)
	return true
