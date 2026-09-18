extends SocialUnlockConditionBase
class_name SocialUnlockPBAboveCondition

var amount:float = 0.0

func _init(_am:float) -> void:
	amount = _am

func isSatisfied(_context:SocialInteractionContext) -> bool:
	var theValue:float = GM.main.relationshipSystem.getPowerBalance(_context.main.getCharID(), _context.target.getCharID())
	if(theValue < amount):
		return false
	return true

func isCloseToBeingSatisfied(_context:SocialInteractionContext) -> bool:
	var theValue:float = GM.main.relationshipSystem.getPowerBalance(_context.main.getCharID(), _context.target.getCharID())
	var theDiffAm:float = amount - theValue
	if(theDiffAm > 0.5 || theValue <= 0.0):
		return false
	return true

# add an imaginary 'requires' before this message
# ex: 'requires' affection above xxx
func getUnlockMessage(_context:SocialInteractionContext) -> String:
	return "power balance above "+str(Util.roundF(amount*100.0, 2))+"%"
