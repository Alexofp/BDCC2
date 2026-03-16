extends RefCounted
class_name PawnActionBase

const C_TALK := "Talk"

var id:String = ""
var alwaysCheckedSelf:bool = false
var alwaysCheckedOtherPawn:bool = false
var alwaysCheckedSelfQuickAction:bool = false
var alwaysCheckedOtherPawnQuickAction:bool = false
var alwaysPriority:int = 0 # Higher priority -> higher in the list

var checkDoingAnyActions:bool = true
var checkIsTargetOfAnyAciton:bool = true

var canDoWhileCollapsed:bool = false
var canDoWhileDefeated:bool = false

var subCategory:Array[String]

func getVisibleName(_context:PawnActionContext) -> String:
	return "CHANGE ME"

func canStartAction(_context:PawnActionContext) -> bool:
	if(checkDoingAnyActions && _context.pawn.isDoingAnyDelayedActions()):
		return false
	if(checkIsTargetOfAnyAciton && _context.pawn.isTargetOfAnyDelayedActions()):
		return false
	if(!canDoWhileCollapsed && _context.pawn.isCollapsed()):
		return false
	if(!canDoWhileDefeated && _context.pawn.isDefeated()):
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

func startDelayedAction(_text:String, _context:PawnActionContext, _timer:float, _args:Array = [], _extras:Array[ActionSystemTarget] = []) -> ActionSystemEntry:
	var newEntry := ActionSystemEntry.new()
	
	var mainTarget := ActionSystemTarget.new()
	mainTarget.node = _context.target
	
	#newEntry.actionText = _text
	newEntry.user = _context.pawn
	newEntry.target = mainTarget
	newEntry.action = self
	newEntry.timeFull = _timer
	newEntry.args = _args
	
	for extra in _extras:
		newEntry.addExtraTarget(extra)
	
	newEntry.setActionText(_text)
	GM.actionSystem.startAction(newEntry)
	
	return newEntry

func getSubCategory() -> Array[String]:
	return subCategory
