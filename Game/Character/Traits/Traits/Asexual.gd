extends TraitBase

func _init() -> void:
	id = Trait.Asexual
	compatibilityType = "slut"
	generateScore = 0.3
	
	personalityChanges = {
		PersonalityStat.Libido: Vector2(-1.5, -0.5),
	}
	interactionAgreeChanceMods = {
		"Seduce": -0.2,
		"OfferSex": -0.5,
		"HoldHands": -0.1,
	}
	lustGainMult = 0.5
	
	passiveAffectionLossMult = 0.5
	affectionGainMult = 1.3

func getName() -> String:
	return "Asexual"

func getDescription() -> String:
	return "Doesn't enjoy doing anything sexual. Gains affection a bit faster"

func proccessSocialInteractionTags(_tags:Dictionary[int, float], _ourPawn:CharacterPawn, _targetPawn:CharacterPawn):
	_tags[IATag.OfferSex] *= 0.1
	_tags[IATag.Lusty] *= 0.5
