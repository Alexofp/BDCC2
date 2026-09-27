extends SocialUnlockConditionBase
class_name SocialUnlockHasStatusEffectCondition

var effectID:String
var showEffectUnlockMessage:bool = false

func _init(_effectID:String, _showMessage:bool = false) -> void:
	effectID = _effectID
	showEffectUnlockMessage = _showMessage

func isSatisfied(_context:SocialInteractionContext) -> bool:
	if(!_context.target.hasStatusEffect(effectID)):
		return false
	return true

func isCloseToBeingSatisfied(_context:SocialInteractionContext) -> bool:
	return showEffectUnlockMessage

func getUnlockMessage(_context:SocialInteractionContext) -> String:
	if(showEffectUnlockMessage && GlobalRegistry.hasStatusEffect(effectID)):
		var theStatusEffect:StatusEffectBase = GlobalRegistry.getStatusEffect(effectID)
		if(theStatusEffect):
			return "'"+theStatusEffect.getName()+"' status effect"
	return ""
