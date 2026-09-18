extends SocialInteractionChanceCalculatorBase
class_name SICCChat

func calculateChances(_context:SocialInteractionContext) -> Vector3:
	var _socialExhaustion:float = _context.target.getSocialExhaustion()
	var theChance:float = 1.0 if _socialExhaustion < 0.7 else (1.0 - _socialExhaustion)
	return Vector3(theChance, 0.0, 0.05)
