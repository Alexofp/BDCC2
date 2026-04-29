extends ItemBase

var ballColor:Color = Color("bf0000")

func _init():
	id = "BallGag"

func getName() -> String:
	return "Ball gag"

func getSlot() -> int:
	return InventorySlot.Mouth

func getOptions() -> Dictionary:
	return {
		"ballColor": {
			name = "Ball Color",
			type = "color",
			editors = [EDITOR_INTERACT],
		},
	}

func getSexHideTags() -> Dictionary:
	return {
		SexHideTag.Gag: true,
	}

func isBondageGear() -> bool:
	return true

func prepareBuffs() -> Array[Buff]:
	return [
		Buffs.GaggedSpeechBuff.new(),
		Buffs.OralBlockedBuff.new(),
		Buffs.BitingBlockedBuff.new(),
		Buffs.SuppressionBuff.new(0.15),
	]
