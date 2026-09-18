extends SocialInteractionChanceCalculatorBase
class_name SICCSimple

var critFailChance:float = 0.05
var critWinChance:float = 0.05
var chances:Dictionary[int, Vector4]
var fallbackChance:float = 1.0

func calculateChances(_context:SocialInteractionContext) -> Vector3:
	var _theSocialExhaustion := _context.target.getSocialExhaustion()
	var theChance:float = 0.0 if !chances.is_empty() else fallbackChance
	for theChanceType:int in chances:
		var theVals:Vector4 = chances[theChanceType]
		var theVal:float = SICC.getValuePawns(theChanceType, _context.main, _context.target)
		# Add mood or trait stuff to theVal here?
		var theChanceVal:float = remap(clampf(theVal, theVals.y, theVals.w), theVals.y, theVals.w, theVals.x, theVals.z)
		
		theChance += (1.0-theChance)*theChanceVal
	
	if(_theSocialExhaustion > 0.5):
		theChance *= 1.0-(1.0-(1.5 - _theSocialExhaustion))*0.5 #25% chance debuff at 100% social exhaustion
	
	var _critWin:float = (critWinChance / theChance) if theChance > 0.1 else (critWinChance/0.1) # Makes the good crits more likely if you risk a low chance
	var _critFail:float = critFailChance
	
	return Vector3(theChance, _critFail, _critWin)

func setChance(_type:int, _chanceMin:float, _min:float, _chanceMax:float, _max:float):
	chances[_type] = Vector4(_chanceMin, _min, _chanceMax, _max)

func getActionPostfix(_context:SocialInteractionContext) -> String:
	var theChances:Vector3 = calculateChances(_context)
	var theChance:float = theChances.x
	if(theChance <= 0.0):
		return "Chance 0%"
	if(theChance < 0.05):
		return "Chance <5%"
	if(theChance > 0.95):
		return "Chance >95%"
	
	return "Chance ~"+str(roundf(theChance*20.0)*5.0)+"%"
