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

func isBondageGear() -> bool:
	return true

func prepareBuffs() -> Array[Buff]:
	return [
		Buffs.BlindfoldedBuff.new(),
		Buffs.SuppressionBuff.new(0.2),
	]
