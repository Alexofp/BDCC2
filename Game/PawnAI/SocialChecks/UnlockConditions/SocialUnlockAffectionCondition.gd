extends SocialUnlockConditionBase
class_name SocialUnlockAffectionCondition

var amount:float = 0.0

func _init(_am:float) -> void:
	amount = _am

func isSatisfied(_context:SocialInteractionContext) -> bool:
	var theAffection:float = GM.main.relationshipSystem.getAffection(_context.main.getCharID(), _context.target.getCharID())
	if(theAffection < amount):
		return false
	return true

func isCloseToBeingSatisfied(_context:SocialInteractionContext) -> bool:
	var theAffection:float = GM.main.relationshipSystem.getAffection(_context.main.getCharID(), _context.target.getCharID())
	var theDiffAm:float = amount - theAffection
	if(theDiffAm > 0.5):
		return false
	return true

# add an imaginary 'requires' before this message
# ex: 'requires' affection above xxx
func getUnlockMessage(_context:SocialInteractionContext) -> String:
	return "affection above "+str(Util.roundF(amount*100.0, 2))+"%"
