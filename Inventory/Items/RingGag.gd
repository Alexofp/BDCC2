extends ItemBase

func _init():
	id = "RingGag"

func getName() -> String:
	return "Ring gag"

func getSlot() -> int:
	return InventorySlot.Mouth

func getSexHideTags() -> Dictionary:
	return {
		SexHideTag.Gag: true,
	}
