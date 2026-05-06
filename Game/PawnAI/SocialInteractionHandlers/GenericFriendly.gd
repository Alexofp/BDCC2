extends "res://Game/PawnAI/SocialInteractionHandlers/Generic.gd"

var affectionGain:float = 0.05
var affectionLossDeny:float = 0.025

var socialExhaustionGain:float = 0.3

var agreeAffection:float = -1.0 # The affection must be above this value to agree. Other modifiers can raise or lower it
#var agreeLust:float = 0.0 # The lust must be above this value to agree

var agreeExhaustionStart:float = 0.5
var agreeExhaustionMult:float = 2.0
var agreeMoodMult:float = 1.0



var memorySuccess:String = "" # Added to the target if success >= memorySuccessAbove
var memorySuccessAbove:float = 0.3

var memoryDenied:String = "" # Added to the starter if they got denied

func _init() -> void:
	super._init()
	id = "GenericFriendly"

func trySocialInteraction() -> void:
	var _target := getTargetPawn()
	var _targetPersonality := _target.getPersonality()
	
	var theAffection:float = getAffection()
	
	var theSocialExhaustion:float = _target.getSocialExhaustion()
	theAffection -= agreeExhaustionMult*remap(maxf(theSocialExhaustion, agreeExhaustionStart), agreeExhaustionStart, agreeExhaustionStart+1.0, 0.0, 1.0)
	theAffection += agreeMoodMult * _target.mood.effects.friendlyAgreeMod
	
	Log.Print("Final affection: "+str(Util.roundF(theAffection, 2))+"   Agree affection: "+str(Util.roundF(agreeAffection, 2)))
	
	if(theAffection >= agreeAffection):
		agree = 1.0
	else:
		agree = 0.0

# The interaction is just about to start
func onStart() -> void:
	var theCooldown:float = 0.0
	if(!kind.is_empty()):
		theCooldown = GM.main.relationshipSystem.getActionCooldown(charIDTarget, charIDStarter, kind)
	
	success = 1.0 / (1.0 + theCooldown)
	Log.Print("Success: "+str(int(success*100.0))+"%")

# The interaction has ended
func onEnd() -> void:
	playSuccessNoise(success)
	addAffection(affectionGain, success)
	affectTargetSocialExhaustion(socialExhaustionGain)
	
	if(!kind.is_empty()):
		GM.main.relationshipSystem.addActionCooldown(charIDTarget, charIDStarter, kind, 1.0)
	
	if(success >= memorySuccessAbove):
		addMemoryTarget(memorySuccess)
	
	getTargetPawn().mood.addMood(1.1*success)
	
# The target has denied us
func onDenied() -> void:
	playSuccessNoise(-1.0)
	addAffection(-affectionLossDeny)
	addMemoryStarter(memoryDenied)
