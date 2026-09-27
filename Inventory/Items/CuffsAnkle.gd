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

func isBondageGear() -> bool:
	return true

func prepareBuffs() -> Array[Buff]:
	return [
		Buffs.LegsBoundBuff.new(),
		Buffs.SuppressionBuff.new(0.25),
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
