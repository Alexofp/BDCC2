extends StatusEffectBase

func _init() -> void:
	id = StatusEffect.SocialHorny
	timed = true
	#alwaysChecked = true

func getName() -> String:
	return "Horny!"

func getDescription() -> String:
	return "You would like to do some sex"

func getIconPath() -> String:
	return "res://icon.svg"

func getIconBackgroundColor() -> Color:
	return BG_COLOR_LEWD

func prepareBuffs() -> Array[Buff]:
	return [
		Buffs.SocialInteractionChanceBuff.new("OfferSex", 0.5),
	]

func onSocialInteractionEnd(_interaction:InteractionSocialBase, _role:int):
	if(_interaction.id == "OfferSex"):
		removeMe()
	elif(_interaction.isFail()):
		removeMe()

func onSexEngineResult(_result:SexEngineResult):
	removeMe()
