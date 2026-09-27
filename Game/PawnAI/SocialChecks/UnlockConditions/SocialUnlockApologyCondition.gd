extends SocialUnlockConditionBase
class_name SocialUnlockApologyCondition

var amount:float = 0.0

func _init(_am:float = -0.05) -> void:
	amount = _am

func isSatisfied(_context:SocialInteractionContext) -> bool:
	var theAffection:float = GM.main.relationshipSystem.getAffection(_context.main.getCharID(), _context.target.getCharID())
	if(theAffection > amount):
		return false
	return true

func isCloseToBeingSatisfied(_context:SocialInteractionContext) -> bool:
	return false

# add an imaginary 'requires' before this message
# ex: 'requires' affection above xxx
func getUnlockMessage(_context:SocialInteractionContext) -> String:
	return ""
