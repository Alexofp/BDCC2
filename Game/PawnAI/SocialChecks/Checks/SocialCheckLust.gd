extends SocialCheckBase
class_name SocialCheckLust

var agreeLust:float = 0.0 # The lust must be above this value to agree
var mods:Array[int]
var modMults:Array[float]

var belowStatus:int = SocialInteractionHandler.STATUS_DENY
var aboveStatus:int = SocialInteractionHandler.STATUS_UNCHANGED

func _init(_affection:float) -> void:
	agreeLust = _affection

func getAgreeStatus() -> int:
	var _target := socialHandler.getTargetPawn()
	var _targetPersonality := _target.getPersonality()
	
	var theLust:float = socialHandler.getLust()
	
	var modAm:int = mods.size()
	for _i in modAm:
		var theMod:int = mods[_i]
		var theModMult:float = modMults[_i]
		
		theLust += _target.mood.effects.getMod(theMod)*theModMult
	
	if(theLust < agreeLust):
		return belowStatus
	return aboveStatus

func addMod(_mod:int, _mult:float = 1.0) -> SocialCheckLust:
	mods.append(_mod)
	modMults.append(_mult)
	return self

func setStatus(_below:int, _above:int = SocialInteractionHandler.STATUS_UNCHANGED) -> SocialCheckLust:
	belowStatus = _below
	aboveStatus = _above
	return self
