extends ItemBase

func _init():
	id = "NippleClampsWeight"

func getName() -> String:
	return "Nipple clamps (weights)"

func getSlot() -> int:
	return InventorySlot.Nipples
