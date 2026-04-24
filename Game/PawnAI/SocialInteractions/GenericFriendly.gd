extends "res://Game/PawnAI/SocialInteractions/Generic.gd"

var affectionGain:float = 0.05
var affectionLossDeny:float = 0.025

var socialExhaustionGain:float = 0.3

var agreeBase:float = 0.2
var agreeMinAffection:float = 0.0
var agreeMinAffectionPenalty:float = 0.2
var agreeExhaustionStart:float = 0.7
var agreeExhaustionMult:float = 1.0

var memorySuccess:String = "" # Added to the target if success >= memorySuccessAbove
var memorySuccessAbove:float = 0.3

var memoryDenied:String = "" # Added to the starter if they got denied

func _init() -> void:
	super._init()
	id = "GenericFriendly"

func trySocialInteraction() -> void:
	var _target := getTargetPawn()
	var _targetPersonality := _target.getPersonality()
	var agreeScore:float = 0.0
	
	agreeScore += agreeBase
	agreeScore += affectionPenalty(agreeMinAffection, agreeMinAffectionPenalty)
	agreeScore += socialExhaustionPenalty(agreeExhaustionStart, agreeExhaustionMult)
	#agreeScore += _target.getMood()*0.2 # Bad mood = less likely to agree
	#agreeScore -= _targetPersonality.getStat(PersonalityStat.Mean)*0.2
	
	if(agreeScore >= 0.0):
		agree = 1.0
	else:
		agree = 0.0

# The interaction is just about to start
func onStart() -> void:
	var theCooldown:float = 0.0
	if(!kind.is_empty()):
		theCooldown = GM.main.relationshipSystem.getActionCooldown(charIDTarget, charIDStarter, kind)
	
	success = 1.0 / (1.0 + theCooldown)
	Log.Print("Success: "+str(success))

# The interaction has ended
func onEnd() -> void:
	playSuccessNoise(success)
	addAffection(affectionGain, success)
	affectTargetSocialExhaustion(socialExhaustionGain)
	
	if(!kind.is_empty()):
		GM.main.relationshipSystem.addActionCooldown(charIDTarget, charIDStarter, kind, 1.0)
	
	if(success >= memorySuccessAbove):
		addMemoryTarget(memorySuccess)
	
# The target has denied us
func onDenied() -> void:
	playSuccessNoise(-1.0)
	addAffection(-affectionLossDeny)
	addMemoryStarter(memoryDenied)
