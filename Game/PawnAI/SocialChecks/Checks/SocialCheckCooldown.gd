extends SocialCheckBase
class_name SocialCheckCooldown

var cooldownID:String = ""
var cooldownAmount:float = 1.0

func _init(_cooldown:String, _cooldownAmount:float = 1.0) -> void:
	cooldownID = _cooldown
	cooldownAmount = _cooldownAmount

func onStart():
	var theCooldown:float = 0.0
	if(!cooldownID.is_empty()):
		theCooldown = GM.main.relationshipSystem.getActionCooldown(socialHandler.charIDTarget, socialHandler.charIDStarter, cooldownID)
	
	socialHandler.success = 1.0 / (1.0 + theCooldown)

func onEnd(_status:int):
	if(_status == SocialInteractionHandler.STATUS_AGREE):
		GM.main.relationshipSystem.addActionCooldown(socialHandler.charIDTarget, socialHandler.charIDStarter, cooldownID, cooldownAmount)
	
