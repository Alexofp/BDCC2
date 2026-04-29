extends Object
class_name Buffs

class BlindfoldedBuff extends Buff:
	func _init() -> void:
		pass
	func getName() -> String:
		return "Blindfolded"
	func getColor() -> Color:
		return COLOR_DEBUFF
	func apply(_holder:BuffsHolder):
		_holder.boundFlags |= BuffsHolder.BOUND_BLINDFOLDED

class SuppressionBuff extends Buff:
	var suppression:float
	func _init(_sup:float) -> void:
		suppression = _sup
	func getName() -> String:
		return "Suppression"
	func getBuffText() -> String:
		return buffF(suppression*100.0)+"%"
	func getColor() -> Color:
		return COLOR_DEBUFF if suppression > 0.0 else COLOR_BUFF
	func apply(_holder:BuffsHolder):
		_holder.supression += suppression

class ArmsBoundBuff extends Buff:
	func _init() -> void:
		pass
	func getName() -> String:
		return "Arms bound"
	func getColor() -> Color:
		return COLOR_DEBUFF
	func apply(_holder:BuffsHolder):
		_holder.boundFlags |= BuffsHolder.BOUND_ARMS

class HandsBlockedBuff extends Buff:
	func _init() -> void:
		pass
	func getName() -> String:
		return "Hands blocked"
	func getColor() -> Color:
		return COLOR_DEBUFF
	func apply(_holder:BuffsHolder):
		_holder.boundFlags |= BuffsHolder.BOUND_HANDS

class LegsBoundBuff extends Buff:
	func _init() -> void:
		pass
	func getName() -> String:
		return "Legs bound"
	func getColor() -> Color:
		return COLOR_DEBUFF
	func apply(_holder:BuffsHolder):
		_holder.boundFlags |= BuffsHolder.BOUND_LEGS

class GaggedSpeechBuff extends Buff:
	func _init() -> void:
		pass
	func getName() -> String:
		return "Gagged speech"
	func getColor() -> Color:
		return COLOR_DEBUFF
	func apply(_holder:BuffsHolder):
		_holder.boundFlags |= BuffsHolder.BOUND_GAGGED_SPEECH

class OralBlockedBuff extends Buff:
	func _init() -> void:
		pass
	func getName() -> String:
		return "Oral sex blocked"
	func getColor() -> Color:
		return COLOR_DEBUFF
	func apply(_holder:BuffsHolder):
		_holder.boundFlags |= BuffsHolder.BOUND_ORAL_BLOCKED

class BitingBlockedBuff extends Buff:
	func _init() -> void:
		pass
	func getName() -> String:
		return "Biting blocked"
	func getColor() -> Color:
		return COLOR_DEBUFF
	func apply(_holder:BuffsHolder):
		_holder.boundFlags |= BuffsHolder.BOUND_BITING_BLOCKED

class PainThresholdBuff extends Buff:
	var pain:float
	func _init(_pain:float) -> void:
		pain = _pain
	func getName() -> String:
		return "Pain threshold"
	func getBuffText() -> String:
		return buffF(pain*100.0)
	func getColor() -> Color:
		return COLOR_BUFF if pain >= 0 else COLOR_DEBUFF
	func apply(_holder:BuffsHolder):
		_holder.painThreshold += pain
