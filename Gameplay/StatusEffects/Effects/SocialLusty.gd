extends StatusEffectBase

func _init() -> void:
	id = StatusEffect.SocialLusty
	timed = true
	#alwaysChecked = true

func getName() -> String:
	return "Lusty!"

func getDescription() -> String:
	return "You feel more open to lusty interactions"

func getIconPath() -> String:
	return "res://icon.svg"

func getIconBackgroundColor() -> Color:
	return BG_COLOR_LEWD

func prepareBuffs() -> Array[Buff]:
	return [
		Buffs.SocialInteractionChanceBuff.new("Seduce", 0.5),
	]

func onSocialInteractionEnd(_interaction:InteractionSocialBase, _role:int):
	if(_interaction.id == "Seduce"):
		removeMe()
	elif(_interaction.isFail()):
		removeMe()

func onSexEngineResult(_result:SexEngineResult):
	removeMe()
