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
