extends ItemBase

func _init():
	id = "NippleClampsWeight"

func getName() -> String:
	return "Nipple clamps (weights)"

func getSlot() -> int:
	return InventorySlot.Nipples

func getSexHideTags() -> Dictionary:
	return {
		SexHideTag.NipplesBigPiercing: true,
	}

func isBondageGear() -> bool:
	return true

func prepareBuffs() -> Array[Buff]:
	return [
		Buffs.SuppressionBuff.new(0.2),
	]

func getBuyPrice() -> int:
	return 12

func getItemValues() -> Array[ItemValue]:
	return [
		ItemValue.baseValue(0.5),
		ItemValue.itemValueTagBased(ItemValueTag.KinkyClothing, 1.0),
		ItemValue.itemValueTagBased(ItemValueTag.PrincessGift, 1.0),
	]
