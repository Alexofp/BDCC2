extends TraitBase

func _init() -> void:
	id = Trait.Bully
	compatibilityType = "mean"
	
	personalityChanges = {
		PersonalityStat.Mean: Vector2(0.5, 0.9),
		PersonalityStat.Dominant: Vector2(0.1, 0.2),
	}
	values = {
		TraitValue.AffectionGain: 0.7,
	}
	itemTagValue = {
		ItemValueTag.BondageGear: 0.3,
	}

func getName() -> String:
	return "Bully"

func getDescription() -> String:
	return "Likes to be mean to others"

func proccessSocialInteractionTags(_tags:Dictionary[int, float], _ourPawn:CharacterPawn, _targetPawn:CharacterPawn):
	_tags[IATag.Mean] *= 2.0
	_tags[IATag.StartFight] *= 1.4
	_tags[IATag.Helpful] *= 0.6
