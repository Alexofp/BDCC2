extends SocialInteractionHandler

var affectionGain:float = 0.05
var affectionLossDeny:float = 0.025

var socialExhaustionGain:float = 0.3

var memorySuccess:String = "" # Added to the target if success >= memorySuccessAbove
var memorySuccessAbove:float = 0.3

var memoryDenied:String = "" # Added to the starter if they got denied

func _init() -> void:
	super._init()
	id = "GenericFriendly"

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


func setKind(_t:String):
	kind = _t
