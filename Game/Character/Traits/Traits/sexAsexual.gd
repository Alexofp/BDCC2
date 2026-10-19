extends TraitBase

func _init() -> void:
	id = Trait.Asexual
	compatibilityType = "sex"
	generateScore = 0.3
	
	personalityChanges = {
		PersonalityStat.Libido: Vector2(-1.5, -0.5),
	}
	interactionAgreeChanceMods = {
		"Seduce": -0.2,
		"OfferSex": -0.5,
		"HoldHands": -0.1,
	}
	
	values = {
		TraitValue.PassiveAffectionLoss: 0.5,
		TraitValue.AffectionGain: 1.3,
		TraitValue.LustGain: 0.5,
	}
	itemTagValue = {
		ItemValueTag.KinkyClothing: -0.3,
	}
	fetishChangesReceiving = {
		Fetish.SexVaginal: Vector2(-0.5, 0.0),
		Fetish.SexAnal: Vector2(-0.5, 0.0),
		Fetish.Tribadism: Vector2(-0.5, 0.0),
	}
	fetishChangesPerforming = {
		Fetish.SexVaginal: Vector2(-0.5, 0.0),
		Fetish.SexAnal: Vector2(-0.5, 0.0),
		Fetish.Tribadism: Vector2(-0.5, 0.0),
	}

func getName() -> String:
	return "Asexual"

func getDescription() -> String:
	return "Doesn't enjoy doing anything sexual. Gains affection a bit faster"

func proccessSocialInteractionTags(_tags:Dictionary[int, float], _ourPawn:CharacterPawn, _targetPawn:CharacterPawn):
	multTag(_tags, IATag.OfferSex, 0.1)
	multTag(_tags, IATag.Lusty, 0.5)
