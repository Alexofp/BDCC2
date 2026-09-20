extends StatusEffectBase

func _init() -> void:
	id = StatusEffect.TestEffect
	timed = true
	#alwaysChecked = true

func getName() -> String:
	return "TEST EFFECT!"

func getDescription() -> String:
	return "Meow meow meow nyaaa!"

func getIconPath() -> String:
	return "res://icon.svg"

func getIconBackgroundColor() -> Color:
	return BG_COLOR_LEWD

func shouldApplyTo(_char:BaseCharacter) -> bool:
	return _char.hasReachablePenis()

func prepareBuffs() -> Array[Buff]:
	return [
		Buffs.PainThresholdBuff.new(-0.8),
	]
