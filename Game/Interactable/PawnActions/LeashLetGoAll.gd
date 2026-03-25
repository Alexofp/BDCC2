extends PawnActionBase

func _init() -> void:
	id = "LeashLetGoAll"
	alwaysCheckBitfield = CHECK_SELF
	alwaysPriority = -6

func getVisibleName(_context:PawnActionContext) -> String:
	return "Unleash all"

func canDoAction(_context:PawnActionContext) -> bool:
	var allLeashes := GM.leashSystem.getAllLeashesOfSourceNode(_context.pawn)
	if(allLeashes.is_empty()):
		return false
	return true

func doAction(_context:PawnActionContext) -> bool:
	var allLeashes := GM.leashSystem.getAllLeashesOfSourceNode(_context.pawn)
	for leash in allLeashes.duplicate():
		leash.queue_free()
	
	GM.pawnRegistry.addHoverTextGlobal(_context.pawn, "{user.You} {user.youVerb release} all {user.yourHis} leashes!", {user=_context.pawn.getCharID()})
	return true
