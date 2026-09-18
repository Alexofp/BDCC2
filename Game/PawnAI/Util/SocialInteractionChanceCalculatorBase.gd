extends RefCounted
class_name SocialInteractionChanceCalculatorBase

var id:String

func setInteraction(_interaction:InteractionSocialBase):
	id = _interaction.id

# return Vec3(successChance, criticalFailChanceIfNoSuccess, criticalWinChanceIfSucess)
func calculateChances(_context:SocialInteractionContext) -> Vector3:
	return Vector3(0.5, 0.05, 0.05)

func getActionPostfix(_context:SocialInteractionContext) -> String:
	return ""
