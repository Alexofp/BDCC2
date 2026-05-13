extends RefCounted
class_name SocialUnlockConditionBase

func isSatisfied(_context:SocialInteractionContext) -> bool:
	return true

func isCloseToBeingSatisfied(_context:SocialInteractionContext) -> bool:
	return true

# add an imaginary 'requires' before this message
# ex: 'requires' affection above xxx
func getUnlockMessage(_context:SocialInteractionContext) -> String:
	return "affection above 50%"

func getScore(_context:SocialInteractionContext) -> float:
	return 0.0
