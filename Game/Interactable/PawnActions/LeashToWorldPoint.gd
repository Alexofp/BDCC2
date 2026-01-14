extends PawnActionBase

func _init() -> void:
	id = "LeashToWorldPoint"

func getVisibleName(_context:PawnActionContext) -> String:
	return "Leash "+str(_context.getArg(3, "X"))+" to point"

func canDoAction(_context:PawnActionContext) -> bool:
	#if(hasLeash(_context.pawn.getCharID(), _context.target.getCharID())):
	#	return false
	return true

func doAction(_context:PawnActionContext) -> bool:
	var userLeashPoint:String = _context.getArg(0, "")
	var targetPawnID:String = _context.getArg(1, "")
	var targetPawnPoint:String = _context.getArg(2, "")
	
	var targetPawn := GM.pawnRegistry.getPawn(targetPawnID)
	if(!targetPawn):
		return false
	
	var theCurrentLeash := GM.leashSystem.findPawnLeashSimple(_context.pawn, userLeashPoint, targetPawn, targetPawnPoint)
	if(!theCurrentLeash):
		return false
	
	var theSettings := theCurrentLeash.leashSettings.makeCopy()
	theCurrentLeash.queue_free()
	
	GM.leashSystem.connectLeash(
		LeashPointConnection.createLeashpoint(_context.target),
		LeashPointConnection.createPawnLeashpoint(targetPawn, targetPawnPoint),
		theSettings)
	
	#startDelayedAction("{user.You} {user.youAre} trying to leash {target.you}!", _context, 2.0, _context.args).setTimerType(ActionSystemEntry.TIMER_CAN_DENY)
	return true
