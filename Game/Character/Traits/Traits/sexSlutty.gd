extends TraitBase

func _init() -> void:
	id = Trait.Slutty
	compatibilityType = "sex"
	
	personalityChanges = {
		PersonalityStat.Libido: Vector2(0.5, 0.9),
		PersonalityStat.Perceptive: Vector2(-0.2, -0.1),
		PersonalityStat.Dominant: Vector2(-0.5, -0.2),
	}
	fetishChangesReceiving = {
		Fetish.SexVaginal: Vector2(0.2, 0.8),
		Fetish.SexAnal: Vector2(0.2, 0.8),
	}
	interactionAgreeChanceMods = {
		"Flirt": 0.3,
		"Seduce": 0.3,
		"OfferSex": 0.3,
		"HoldHands": 0.3,
		"Kiss": 0.3,
	}
	values = {
		TraitValue.LustGain: 1.3,
		TraitValue.PassiveLustLoss: 0.5,
		TraitValue.PowerBalanceLoss: 1.2,
	}
	itemTagValue = {
		ItemValueTag.KinkyClothing: 0.6,
	}

func getName() -> String:
	return "Slutty"

func getDescription() -> String:
	return "Likes doing sex and prostitution"

func proccessSocialInteractionTags(_tags:Dictionary[int, float], _ourPawn:CharacterPawn, _targetPawn:CharacterPawn):
	multTag(_tags, IATag.OfferSex, 2.0)
	multTag(_tags, IATag.Lusty, 2.0)
