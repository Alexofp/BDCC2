extends SocialCheckBase
class_name SocialEffectAddAffection

var successAffection:float = 0.0
var denyAffection:float = 0.0

func _init(_success:float, _deny:float = 0.0) -> void:
	successAffection = _success
	denyAffection = _deny

func onEnd(_status:int):
	if(_status == SocialInteractionHandler.STATUS_AGREE):
		socialHandler.addAffection(successAffection, socialHandler.success)
	elif(_status == SocialInteractionHandler.STATUS_DENY):
		socialHandler.addAffection(denyAffection, socialHandler.success)
