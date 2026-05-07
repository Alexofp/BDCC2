extends SocialCheckBase
class_name SocialEffectAddAffection

var successAffection:float = 0.0
var denyAffection:float = 0.0

func _init(_success:float, _deny:float = 0.0) -> void:
	successAffection = _success
	denyAffection = _deny

func onEnd(_isDeny:bool):
	if(!_isDeny):
		socialHandler.addAffection(successAffection*socialHandler.success)
	else:
		socialHandler.addAffection(denyAffection)
