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

func getBuyPrice() -> int:
	return 7

func getItemValues() -> Array[ItemValue]:
	return [
		ItemValue.baseValue(0.2),
		ItemValue.personalityBased(PersonalityStat.Dominant, 0.5),
		ItemValue.personalityBased(PersonalityStat.Mean, 0.2),
		ItemValue.itemValueTagBased(ItemValueTag.BondageGear, 1.0),
	]
