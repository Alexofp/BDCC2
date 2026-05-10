extends SocialCheckBase
class_name SocialCheckAffection

var agreeAffection:float = -1.0 # The affection must be above this value to agree. Other modifiers can raise or lower it
var mods:Array[int]
var modMults:Array[float]

var belowStatus:int = SocialInteractionHandler.STATUS_DENY
var aboveStatus:int = SocialInteractionHandler.STATUS_UNCHANGED

func _init(_affection:float) -> void:
	agreeAffection = _affection

func getAgreeStatus() -> int:
	var _target := socialHandler.getTargetPawn()
	var _targetPersonality := _target.getPersonality()
	
	var theAffection:float = socialHandler.getAffection()
	
	var theFinalMod:float = 1.0
	var modAm:int = mods.size()
	for _i in modAm:
		var theMod:int = mods[_i]
		var theModMult:float = modMults[_i]
		
		theFinalMod *= _target.mood.effects.getMod(theMod)*theModMult
		#theAffection += _target.mood.effects.getMod(theMod)*theModMult
	
	if(theAffection >= 0.0):
		theAffection *= theFinalMod
	elif(absf(theFinalMod) >= 0.01):
		theAffection /= theFinalMod
	
	if(theAffection < agreeAffection):
		return belowStatus
	return aboveStatus

func addMod(_mod:int, _mult:float = 1.0) -> SocialCheckAffection:
	mods.append(_mod)
	modMults.append(_mult)
	return self

func setStatus(_below:int, _above:int = SocialInteractionHandler.STATUS_UNCHANGED) -> SocialCheckAffection:
	belowStatus = _below
	aboveStatus = _above
	return self
