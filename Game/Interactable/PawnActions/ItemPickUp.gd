extends PawnActionBase

func _init() -> void:
	id = "ItemPickUp"

func getVisibleName(_context:PawnActionContext) -> String:
	return "Pick up "+_context.target.inventory.getPickupName()

func canDoAction(_context:PawnActionContext) -> bool:
	return true

func doAction(_context:PawnActionContext) -> bool:
	var theCharacter := _context.pawn.getCharacter()
	if(!theCharacter):
		return false
	var theInv:Inventory = _context.target.inventory
	while(!theInv.items.is_empty()):
		var theItem:ItemBase = theInv.items.front()
		theInv.removeItem(theItem)
		theCharacter.inventory.addItem(theItem)
	_context.target.queue_free()
	return true
