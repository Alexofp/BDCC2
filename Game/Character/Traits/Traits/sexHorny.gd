extends TraitBase

func _init() -> void:
	id = Trait.Horny
	compatibilityType = "sex"
	
	personalityChanges = {
		PersonalityStat.Libido: Vector2(0.5, 0.9),
	}
	fetishChangesPerforming = {
		Fetish.SexVaginal: Vector2(0.2, 0.5),
		Fetish.SexAnal: Vector2(0.2, 0.5),
		Fetish.Tribadism: Vector2(0.2, 0.5),
	}
	fetishChangesReceiving = {
		Fetish.SexVaginal: Vector2(0.2, 0.5),
		Fetish.SexAnal: Vector2(0.2, 0.5),
		Fetish.Tribadism: Vector2(0.2, 0.5),
	}
	values = {
		TraitValue.LustGain: 1.3,
	}

func getName() -> String:
	return "Horny"

func getDescription() -> String:
	return "Likes doing sex"

func proccessSocialInteractionTags(_tags:Dictionary[int, float], _ourPawn:CharacterPawn, _targetPawn:CharacterPawn):
	_tags[IATag.OfferSex] *= 2.0
	_tags[IATag.Lusty] *= 1.5
