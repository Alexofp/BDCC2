extends PawnActionBase

func _init() -> void:
	id = "ItemActionDelayed"

func getVisibleName(_context:PawnActionContext) -> String:
	return "Shouldn't see this"

func canDoAction(_context:PawnActionContext) -> bool:
	return true

func doDelayedAction(_context:PawnActionContext) -> bool:
	var theCharacter := _context.pawn.getCharacter()
	if(!theCharacter):
		return false
	var theInv:Inventory = theCharacter.getInventory()
	
	var theItem:ItemBase = theInv.findItemByUniqueID(_context.args[0])
	if(!theItem):
		return false
	theItem.doActionFinal(_context.args[1], _context.args[2])
	return true
