extends TraitBase

func _init() -> void:
	id = Trait.Brat
	compatibilityType = "brat"
	
	personalityChanges = {
		PersonalityStat.Bratty: Vector2(0.2, 0.9),
	}
	fetishChangesReceiving = {
		Fetish.Bondage: Vector2(0.1, 0.8),
	}
	values = {
		TraitValue.PowerBalanceGain: 0.8,
		TraitValue.PowerBalanceLoss: 1.3,
	}
	itemTagValue = {
		ItemValueTag.BondageGear: 0.2,
		ItemValueTag.KinkyClothing: 0.3,
	}

func getName() -> String:
	return "Brat"

func getDescription() -> String:
	return "Likes to disobey"

func proccessSocialInteractionTags(_tags:Dictionary[int, float], _ourPawn:CharacterPawn, _targetPawn:CharacterPawn):
	_tags[IATag.Submit] *= 1.2
	_tags[IATag.Submission] *= 2.0
	_tags[IATag.Domination] *= 1.5
	_tags[IATag.Apologize] *= 1.3
