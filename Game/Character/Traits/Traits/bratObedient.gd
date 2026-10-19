extends TraitBase

func _init() -> void:
	id = Trait.Obedient
	compatibilityType = "brat"
	
	personalityChanges = {
		PersonalityStat.Bratty: Vector2(-0.9, -0.3),
		PersonalityStat.Dominant: Vector2(-0.3, 0.0),
	}
	fetishChangesReceiving = {
		Fetish.Bondage: Vector2(0.1, 0.3),
	}
	values = {
		TraitValue.PowerBalanceGain: 0.9,
		TraitValue.PowerBalanceLoss: 1.1,
	}
	itemTagValue = {
		ItemValueTag.BondageGear: 0.3,
		ItemValueTag.KinkyClothing: 0.1,
	}

func getName() -> String:
	return "Obedient"

func getDescription() -> String:
	return "Likes to obey"

func proccessSocialInteractionTags(_tags:Dictionary[int, float], _ourPawn:CharacterPawn, _targetPawn:CharacterPawn):
	multTag(_tags, IATag.Submit, 1.2)
	multTag(_tags, IATag.Submission, 3.0)
	multTag(_tags, IATag.Domination, 0.8)
	multTag(_tags, IATag.Apologize, 1.1)
