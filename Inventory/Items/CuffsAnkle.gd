extends ItemBase

func _init():
	id = "CuffsAnkle"

func getName() -> String:
	return "Ankle cuffs"

func getSlot() -> int:
	return InventorySlot.Ankles

func shouldHobbleLegs() -> bool:
	return true

func getSexHideTags() -> Dictionary:
	return {
		SexHideTag.LegRestraint: true,
		SexHideTag.AnkleCuffs: true,
	}
