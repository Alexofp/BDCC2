extends SocialInteractionChanceCalculatorBase
class_name SICCAlways

var critChance:float = 0.0
var critFailChance:float = 0.0

func calculateChances(_context:SocialInteractionContext) -> Vector3:
	return Vector3(1.0, critFailChance, critChance)

func withCritChances(_failChance:float, _critWinChance:float) -> SICCAlways:
	critChance = _critWinChance
	critFailChance = _failChance
	return self
