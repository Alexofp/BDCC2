extends RefCounted
class_name PawnActionBase

const C_TALK := "Talk"

var id:String = ""

const CHECK_SELF := 1
const CHECK_OTHER := 2
const CHECK_SELF_QUICKACTION := 4
const CHECK_OTHER_QUICKACTION := 8
var alwaysCheckBitfield:int = 0

var alwaysPriority:int = 0 # Higher priority -> higher in the list

const CAN_COLLAPSED := 1
const CAN_DEFEATED := 2
const CAN_COUPLE_ANIM := 4
const CAN_WHILE_TARGET_OF_ANY_ACTION := 8
const CAN_WHILE_DOING_ANY_ACTION := 16
var canDoBitfield:int = 0

var subCategory:Array[String]

func getVisibleName(_context:PawnActionContext) -> String:
	return "CHANGE ME"

func canStartAction(_context:PawnActionContext) -> bool:
	if(!(canDoBitfield & CAN_WHILE_DOING_ANY_ACTION) && _context.pawn.isDoingAnyDelayedActions()):
		return false
	if(!(canDoBitfield & CAN_WHILE_TARGET_OF_ANY_ACTION) && _context.pawn.isTargetOfAnyDelayedActions()):
		return false
	if(!(canDoBitfield & CAN_COLLAPSED) && _context.pawn.isCollapsed()):
		return false
	if(!(canDoBitfield & CAN_DEFEATED) && _context.pawn.isDefeated()):
		return false
	if(!(canDoBitfield & CAN_COUPLE_ANIM) && _context.pawn.isDoingACoupleAnimation()):
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

func addHoverText(_pawn:CharacterPawn, _text:String, _context:PawnActionContext):
	GM.pawnRegistry.addHoverTextGlobal(_pawn, "{user.You} {user.youVerb leash|leashes} {target.you}!", {user=_context.pawn.getCharID(), target=_context.target.getCharID()})
