extends ItemBase

func _init():
	id = "InmateCollar"

func getName() -> String:
	return "Inmate collar"

func getSlot() -> int:
	return InventorySlot.Collar
