extends SocialCheckBase
class_name SocialCheckExhaustion

var maxExhaustion:float = 0.8
var exhaustionMoodMult:float = 1.0

func _init(_exhaustion:float = 0.8, _moodMult:float = 1.0) -> void:
	maxExhaustion = _exhaustion
	exhaustionMoodMult = _moodMult

func getAgreeStatus() -> int:
	var _target := socialHandler.getTargetPawn()
	var theSocialExhaustion:float = _target.getSocialExhaustion()
	
	var theExhaustionMod:float = _target.mood.effects.exhaustionMod
	theSocialExhaustion *= (1.0 + theExhaustionMod*exhaustionMoodMult)
	
	if(theSocialExhaustion > maxExhaustion):
		return SocialInteractionHandler.STATUS_DENY
	return SocialInteractionHandler.STATUS_UNCHANGED
