extends RefCounted
class_name TraitBase

# Traits shouldn't have any state. If you think about adding state, don't

var id:String = ""
var compatibilityType:String = "" # You can only have 1 trait with the same compatibilityType
var generateScore:float = 1.0 # The higher the number, the more likely that this trait will be picked

# Vector2 means the final value shift is calculated as a random number between X and Y of the vec2
var personalityChanges:Dictionary[String, Vector2] # personality stat = vec2(min change, max change)
var fetishChangesPerforming:Dictionary[String, Vector2] # fetish = vec2(min change, max change)
var fetishChangesReceiving:Dictionary[String, Vector2] # fetish = vec2(min change, max change)

var interactionAgreeChanceMods:Dictionary[String, float] # 1.0 = will always agree, 0.1 = 10% closer to agreeing, -1.0 = will never agree, -0.3 = 30% less chance of agreeing
#"Flirt": 0.3, # Makes this character more likely to agree to a Flirting attempt by 30%

var itemTagValue:Dictionary[int, float] # Adds to the item value depending on the item tags

var values:Dictionary[int, float]

func getName() -> String:
	return "Fill me"

func getDescription() -> String:
	return "Explain me!"

func proccessSocialInteractionTags(_tags:Dictionary[int, float], _ourPawn:CharacterPawn, _targetPawn:CharacterPawn):
	pass

func processSocialGoalScore(_score:float, _ourPawn:CharacterPawn, _targetPawn:CharacterPawn):
	return _score
