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
