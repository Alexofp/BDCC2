extends ItemBase

func _init():
	id = "Blindfold"

func getName() -> String:
	return "Blindfold"

func getSlot() -> int:
	return InventorySlot.Eyes

func getSexHideTags() -> Dictionary:
	return {
		SexHideTag.Blindfold: true,
	}
