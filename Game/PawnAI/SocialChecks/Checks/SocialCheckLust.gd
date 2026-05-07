extends SocialCheckBase
class_name SocialCheckLust

var agreeLust:float = 0.0 # The lust must be above this value to agree
var mods:Array[int]
var modMults:Array[float]

func _init(_affection:float) -> void:
	agreeLust = _affection

func shouldAgree() -> bool:
	var _target := socialHandler.getTargetPawn()
	var _targetPersonality := _target.getPersonality()
	
	var theLust:float = socialHandler.getLust()
	
	var modAm:int = mods.size()
	for _i in modAm:
		var theMod:int = mods[_i]
		var theModMult:float = modMults[_i]
		
		theLust += _target.mood.effects.getMod(theMod)*theModMult
	
	if(theLust >= agreeLust):
		return true
	return false

func addMod(_mod:int, _mult:float = 1.0) -> SocialCheckLust:
	mods.append(_mod)
	modMults.append(_mult)
	return self
