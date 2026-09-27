extends SocialUnlockConditionBase
class_name SocialUnlockOrCondition

var condition1:SocialUnlockConditionBase = null
var condition2:SocialUnlockConditionBase = null

func _init(_cond1:SocialUnlockConditionBase, _cond2:SocialUnlockConditionBase) -> void:
	condition1 = _cond1
	condition2 = _cond2

func isSatisfied(_context:SocialInteractionContext) -> bool:
	return condition1.isSatisfied(_context) || condition2.isSatisfied(_context)

func isCloseToBeingSatisfied(_context:SocialInteractionContext) -> bool:
	return condition1.isCloseToBeingSatisfied(_context) || condition2.isCloseToBeingSatisfied(_context)

# add an imaginary 'requires' before this message
# ex: 'requires' affection above xxx
func getUnlockMessage(_context:SocialInteractionContext) -> String:
	var _message1:String = condition1.getUnlockMessage(_context)
	var _message2:String = condition2.getUnlockMessage(_context)
	
	if(_message1.is_empty()):
		return _message2
	if(_message2.is_empty()):
		return _message1
	
	return _message1+" OR "+_message2
