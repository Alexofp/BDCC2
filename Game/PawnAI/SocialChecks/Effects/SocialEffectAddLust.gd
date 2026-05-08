extends SocialCheckBase
class_name SocialEffectAddLust

var successLust:float = 0.0
var denyLust:float = 0.0

func _init(_success:float, _deny:float = 0.0) -> void:
	successLust = _success
	denyLust = _deny

func onEnd(_status:int):
	if(_status == SocialInteractionHandler.STATUS_AGREE):
		socialHandler.addLust(successLust*socialHandler.success)
	elif(_status == SocialInteractionHandler.STATUS_DENY):
		socialHandler.addLust(denyLust)
