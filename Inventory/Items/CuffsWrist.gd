extends ItemBase

func _init():
	id = "CuffsWrist"

func getName() -> String:
	return "Wrist cuffs"

func getSlot() -> int:
	return InventorySlot.Wrists

func getSexHideTags() -> Dictionary:
	return {
		SexHideTag.ArmRestraint: true,
		SexHideTag.WristCuffs: true,
	}

func isBondageGear() -> bool:
	return true

func prepareBuffs() -> Array[Buff]:
	return [
		Buffs.ArmsBoundBuff.new(),
		Buffs.SuppressionBuff.new(0.2),
	]
