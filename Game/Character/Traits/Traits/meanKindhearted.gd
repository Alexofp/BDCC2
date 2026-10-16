extends TraitBase

func _init() -> void:
	id = Trait.Kindhearted
	compatibilityType = "mean"
	
	personalityChanges = {
		PersonalityStat.Mean: Vector2(-0.9, -0.5),
		PersonalityStat.Perceptive: Vector2(-0.3, 0.0),
	}

func getName() -> String:
	return "Kindhearted"

func getDescription() -> String:
	return "Pretty much never does any mean interactions"

func proccessSocialInteractionTags(_tags:Dictionary[int, float], _ourPawn:CharacterPawn, _targetPawn:CharacterPawn):
	_tags[IATag.Mean] *= 0.2
	_tags[IATag.StartFight] *= 0.2
	_tags[IATag.Helpful] *= 2.0
	_tags[IATag.Apologize] *= 1.5
	_tags[IATag.GiveGift] *= 1.2
