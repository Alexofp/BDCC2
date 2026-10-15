extends RefCounted
class_name TraitBase

# Traits shouldn't have any state. If you think about adding state, don't

var id:String = ""
var compatibilityType:String = "" # You can only have 1 trait with the same compatibilityType
var generateScore:float = 1.0 # The higher the number, the more likely that this trait will be picked

var personalityChanges:Dictionary[String, Vector2] # personality stat = vec2(min change, max change)
var fetishChangesPerforming:Dictionary[String, Vector2] # fetish = vec2(min change, max change)
var fetishChangesReceiving:Dictionary[String, Vector2] # fetish = vec2(min change, max change)

var affectionGainMult:float = 1.0
var affectionLossMult:float = 1.0
var lustGainMult:float = 1.0
var lustLossMult:float = 1.0
var powerBalanceGainMult:float = 1.0
var powerBalanceLossMult:float = 1.0

var passiveAffectionLossMult:float = 1.0
var passiveLustLossMult:float = 1.0
var passivePowerBalanceLossMult:float = 1.0

var socialExhaustionGainMult:float = 1.0 # Multiplies the gained social exhaustion
var socialExhaustionDecayMult:float = 1.0 # How fast does the social exhaustion go away

var interactionAgreeChanceMods:Dictionary[String, float] # 1.0 = will always agree, 0.1 = 10% closer to agreeing, -1.0 = will never agree, -0.3 = 30% less chance of agreeing

func getName() -> String:
	return "Fill me"

func getDescription() -> String:
	return "Explain me!"

func proccessSocialInteractionTags(_tags:Dictionary[int, float], _ourPawn:CharacterPawn, _targetPawn:CharacterPawn):
	pass

func processSocialGoalScore(_score:float, _ourPawn:CharacterPawn, _targetPawn:CharacterPawn):
	return _score
