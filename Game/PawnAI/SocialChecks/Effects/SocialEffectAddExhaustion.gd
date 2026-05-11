extends SocialCheckBase
class_name SocialEffectAddExhaustion

var success:float = 0.0
var deny:float = 0.0
var starterMult:float = 0.5

func _init(_success:float = 0.2, _deny:float = 0.1, _starterMult:float = 0.5) -> void:
	success = _success
	deny = _deny
	starterMult = _starterMult

func onEnd(_status:int):
	if(_status == SocialInteractionHandler.STATUS_AGREE):
		socialHandler.affectTargetSocialExhaustion(success, starterMult)
	elif(_status == SocialInteractionHandler.STATUS_DENY):
		socialHandler.affectTargetSocialExhaustion(deny, starterMult)
