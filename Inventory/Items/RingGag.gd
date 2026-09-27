extends ItemBase

func _init():
	id = "RingGag"

func getName() -> String:
	return "Ring gag"

func getSlot() -> int:
	return InventorySlot.Mouth

func getSexHideTags() -> Dictionary:
	return {
		SexHideTag.Gag: true,
	}

func isBondageGear() -> bool:
	return true

func prepareBuffs() -> Array[Buff]:
	return [
		Buffs.GaggedSpeechBuff.new(),
		Buffs.BitingBlockedBuff.new(),
		Buffs.SuppressionBuff.new(0.15),
	]

func getBuyPrice() -> int:
	return 5

func getItemValues() -> Array[ItemValue]:
	return [
		ItemValue.baseValue(0.3),
		ItemValue.personalityBased(PersonalityStat.Dominant, 0.5),
		ItemValue.personalityBased(PersonalityStat.Mean, 0.2),
		ItemValue.itemValueTagBased(ItemValueTag.BondageGear, 1.0),
	]
