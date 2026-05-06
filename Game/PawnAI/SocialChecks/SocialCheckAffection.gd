extends SocialCheckBase
class_name SocialCheckAffection

var agreeAffection:float = -1.0 # The affection must be above this value to agree. Other modifiers can raise or lower it
var mods:Array[int]
var modMults:Array[float]

func _init(_affection:float) -> void:
	agreeAffection = _affection

func shouldAgree() -> bool:
	var _target := socialHandler.getTargetPawn()
	var _targetPersonality := _target.getPersonality()
	
	var theAffection:float = socialHandler.getAffection()
	
	var modAm:int = mods.size()
	for _i in modAm:
		var theMod:int = mods[_i]
		var theModMult:float = modMults[_i]
		
		theAffection += _target.mood.effects.getMod(theMod)*theModMult
	
	if(theAffection >= agreeAffection):
		return true
	return false

func addMod(_mod:int, _mult:float = 1.0) -> SocialCheckAffection:
	mods.append(_mod)
	modMults.append(_mult)
	return self
