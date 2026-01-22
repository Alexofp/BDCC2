extends RefCounted
class_name PawnActionBase

var id:String = ""
var alwaysCheckedSelf:bool = false
var alwaysCheckedOtherPawn:bool = false
var alwaysCheckedSelfQuickAction:bool = false
var alwaysCheckedOtherPawnQuickAction:bool = false
var alwaysPriority:int = 0 # Higher priority -> higher in the list

var checkDoingAnyActions:bool = true
var checkIsTargetOfAnyAciton:bool = true

func getVisibleName(_context:PawnActionContext) -> String:
	return "CHANGE ME"

func canStartAction(_context:PawnActionContext) -> bool:
	if(checkDoingAnyActions && _context.pawn.isDoingAnyDelayedActions()):
		return false
	if(checkIsTargetOfAnyAciton && _context.pawn.isTargetOfAnyDelayedActions()):
		return false
	return canDoAction(_context)

func canDoAction(_context:PawnActionContext) -> bool:
	return true

func doAction(_context:PawnActionContext) -> bool:
	#doDelayed(_context, 3.0, [])
	return true

func canDoDelayedAction(_context:PawnActionContext) -> bool:
	return canDoAction(_context)

func doDelayedAction(_context:PawnActionContext) -> bool:
	return true

func startDelayedAction(_text:String, _context:PawnActionContext, _timer:float, _args:Array = []) -> ActionSystemEntry:
	var newEntry := ActionSystemEntry.new()
	
	#newEntry.actionText = _text
	newEntry.user = _context.pawn
	newEntry.target = _context.target
	newEntry.action = self
	newEntry.timeFull = _timer
	newEntry.args = _args
	newEntry.setActionText(_text)
	
	GM.actionSystem.startAction(newEntry)
	
	return newEntry
