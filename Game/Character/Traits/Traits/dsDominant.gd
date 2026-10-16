extends TraitBase

func _init() -> void:
	id = Trait.Dominant
	compatibilityType = "ds"
	
	personalityChanges = {
		PersonalityStat.Dominant: Vector2(0.4, 0.9),
		PersonalityStat.Perceptive: Vector2(0.0, 0.5),
		PersonalityStat.Brave: Vector2(0.0, 0.3),
	}
	fetishChangesPerforming = {
		Fetish.Bondage: Vector2(0.2, 0.8),
		Fetish.SeedMilking: Vector2(0.2, 0.4),
		Fetish.SexVaginal: Vector2(0.1, 0.4),
		Fetish.SexAnal: Vector2(0.1, 0.4),
		Fetish.Tribadism: Vector2(0.1, 0.4),
	}
	values = {
		TraitValue.PowerBalanceGain: 1.3,
		TraitValue.PowerBalanceLoss: 0.8,
	}
	itemTagValue = {
		ItemValueTag.BondageGear: 0.5,
		ItemValueTag.KinkyClothing: 0.3,
		ItemValueTag.Strapon: 0.5,
	}

func getName() -> String:
	return "Dominant"

func getDescription() -> String:
	return "Likes to dominate"

func proccessSocialInteractionTags(_tags:Dictionary[int, float], _ourPawn:CharacterPawn, _targetPawn:CharacterPawn):
	_tags[IATag.Dominate] *= 2.0
	_tags[IATag.Domination] *= 3.0
	_tags[IATag.Submission] *= 0.5
	_tags[IATag.Submit] *= 0.5
