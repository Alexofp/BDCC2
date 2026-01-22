extends ItemBase

func _init():
	id = "InmateCollar"

func getName() -> String:
	return "Inmate collar"

func getSlot() -> int:
	return InventorySlot.Collar

func getSexHideTags() -> Dictionary:
	return {
		SexHideTag.Collar: true,
	}

func isBondageGear() -> bool:
	return true

func getLeashTargets() -> Array[String]:
	return ["collar"]
