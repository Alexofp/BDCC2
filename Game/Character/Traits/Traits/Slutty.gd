extends TraitBase

func _init() -> void:
	id = Trait.Slutty
	compatibilityType = "slut"
	
	personalityChanges = {
		PersonalityStat.Libido: Vector2(0.5, 0.9),
		PersonalityStat.Perceptive: Vector2(-0.2, -0.1),
		PersonalityStat.Dominant: Vector2(-0.5, -0.2),
	}
	interactionAgreeChanceMods = {
		"Flirt": 0.3,
		"Seduce": 0.3,
		"OfferSex": 0.3,
		"HoldHands": 0.3,
		"Kiss": 0.3,
	}
	lustGainMult = 1.3
	passiveLustLossMult = 0.5
	powerBalanceLossMult = 1.2

func getName() -> String:
	return "Slutty"

func getDescription() -> String:
	return "Likes doing sex and prostitution"

func proccessSocialInteractionTags(_tags:Dictionary[int, float], _ourPawn:CharacterPawn, _targetPawn:CharacterPawn):
	_tags[IATag.OfferSex] *= 2.0
	_tags[IATag.Lusty] *= 2.0
