extends ItemBase

func _init():
	id = "Armbinder"

func getName() -> String:
	return "Armbinder"

func getSlot() -> int:
	return InventorySlot.Wrists

func getSexHideTags() -> Dictionary:
	return {
		SexHideTag.ArmRestraint: true,
		SexHideTag.Armbinder: true,
	}

func isBondageGear() -> bool:
	return true

func prepareBuffs() -> Array[Buff]:
	return [
		Buffs.ArmsBoundBuff.new(),
		Buffs.HandsBlockedBuff.new(),
		Buffs.SuppressionBuff.new(0.3),
	]

func getBuyPrice() -> int:
	return 15

func getItemValues() -> Array[ItemValue]:
	return [
		ItemValue.baseValue(0.5),
		ItemValue.personalityBased(PersonalityStat.Dominant, 0.5),
		ItemValue.personalityBased(PersonalityStat.Mean, 0.2),
		ItemValue.itemValueTagBased(ItemValueTag.BondageGear, 1.0),
	]
