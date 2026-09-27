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

func getBuyPrice() -> int:
	return 10

func getItemValues() -> Array[ItemValue]:
	return [
		ItemValue.baseValue(0.3),
		ItemValue.personalityBased(PersonalityStat.Dominant, 0.5, true),
		ItemValue.personalityBased(PersonalityStat.Dominant, -0.3, true),
		ItemValue.personalityBased(PersonalityStat.Mean, 0.4),
		ItemValue.personalityBased(PersonalityStat.Libido, -0.3),
		ItemValue.itemValueTagBased(ItemValueTag.BondageGear, 0.5),
		ItemValue.itemValueTagBased(ItemValueTag.ChastityCage, 1.0),
	]
