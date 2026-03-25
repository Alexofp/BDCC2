extends PawnActionBase

func _init() -> void:
	id = "Leash"
	alwaysPriority = -3

func hasLeash(_char1:CharacterPawn, _char2:CharacterPawn) -> bool:
	return GM.leashSystem.hasLeash(
			LeashPointConnection.createPawnLeashpoint(_char1, "leashholder.R"),
			LeashPointConnection.createPawnLeashpoint(_char2, "collar"),
	)

func getVisibleName(_context:PawnActionContext) -> String:
	if(hasLeash(_context.pawn, _context.target)):
		return "Unleash"
	return "Leash"

func canDoAction(_context:PawnActionContext) -> bool:
	#if(true):
	#	return false
	#if(hasLeash(_context.pawn.getCharID(), _context.target.getCharID())):
	#	return false
	return true

func doAction(_context:PawnActionContext) -> bool:
	if(hasLeash(_context.pawn, _context.target)):
		GM.leashSystem.removeLeash(
			LeashPointConnection.createPawnLeashpoint(_context.pawn, "leashholder.R"),
			LeashPointConnection.createPawnLeashpoint(_context.target, "collar"),
		)
		GM.pawnRegistry.addHoverTextGlobal(_context.pawn, "{user.You} {user.youVerb unleash|unleashes} {target.you}!", {user=_context.pawn.getCharID(), target=_context.target.getCharID()})
		return true
	
	startDelayedAction("{user.You} {user.youAre} trying to leash {target.you}!", _context, 1.0, _context.args).setTimerType(ActionSystemEntry.TIMER_CAN_DENY)
	return true

func doDelayedAction(_context:PawnActionContext) -> bool:
	if(hasLeash(_context.pawn, _context.target)):
		return false
	GM.leashSystem.connectLeash(
		LeashPointConnection.createPawnLeashpoint(_context.pawn, "leashholder.R"),
		LeashPointConnection.createPawnLeashpoint(_context.target, "collar"),
		LeashSettings.createSimple().setSourcePull(1.5).setTargetPull(1.0),
	)
	var theTargetChar:BaseCharacter = _context.target.getCharacter()
	var theInv := theTargetChar.getInventory()
	if(!theInv.hasSlotEquipped(InventorySlot.Collar)):
		var newCollar := GlobalRegistry.createItem("InmateCollar")
		theInv.equipItem(newCollar, InventorySlot.Collar)
	GM.pawnRegistry.addHoverTextGlobal(_context.pawn, "{user.You} {user.youVerb leash|leashes} {target.you}!", {user=_context.pawn.getCharID(), target=_context.target.getCharID()})
	return true
