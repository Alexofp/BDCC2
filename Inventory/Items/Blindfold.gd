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

func getBuyPrice() -> int:
	return 3

func getItemValues() -> Array[ItemValue]:
	return [
		ItemValue.baseValue(0.1),
		ItemValue.personalityBased(PersonalityStat.Dominant, 0.5),
		ItemValue.personalityBased(PersonalityStat.Mean, 0.2),
		ItemValue.itemValueTagBased(ItemValueTag.BondageGear, 1.0),
	]
