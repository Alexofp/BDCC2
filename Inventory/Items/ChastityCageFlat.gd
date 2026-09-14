extends ItemBase

func _init():
	id = "ChastityCageFlat"

func getName() -> String:
	return "Chastity cage (flat)"

func getSlot() -> int:
	return InventorySlot.Penis

func getSexHideTags() -> Dictionary:
	return {
		#SexHideTag.Gag: true,
	}

func isBondageGear() -> bool:
	return true

func prepareBuffs() -> Array[Buff]:
	return [
		Buffs.PenisChastityBuff.new(),
		Buffs.SuppressionBuff.new(0.15),
	]
