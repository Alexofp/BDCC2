extends TraitBase

func _init() -> void:
	id = Trait.Subby
	compatibilityType = "ds"
	
	personalityChanges = {
		PersonalityStat.Dominant: Vector2(-0.9, -0.3),
		PersonalityStat.Bratty: Vector2(-0.4, 0.4),
		PersonalityStat.Brave: Vector2(-0.4, 0.0),
		PersonalityStat.Perceptive: Vector2(-0.2, 0.0),
	}
	fetishChangesReceiving = {
		Fetish.Bondage: Vector2(0.1, 0.8),
		Fetish.SexVaginal: Vector2(0.1, 0.4),
		Fetish.SexAnal: Vector2(0.1, 0.4),
		Fetish.Tribadism: Vector2(0.1, 0.4),
	}
	values = {
		TraitValue.PowerBalanceGain: 0.8,
		TraitValue.PowerBalanceLoss: 1.3,
	}
	itemTagValue = {
		ItemValueTag.BondageGear: 0.5,
		ItemValueTag.KinkyClothing: 0.3,
	}

func getName() -> String:
	return "Subby"

func getDescription() -> String:
	return "Likes to submit"

func proccessSocialInteractionTags(_tags:Dictionary[int, float], _ourPawn:CharacterPawn, _targetPawn:CharacterPawn):
	multTag(_tags, IATag.Submit, 2.0)
	multTag(_tags, IATag.Submission, 3.0)
	multTag(_tags, IATag.Domination, 0.5)
	multTag(_tags, IATag.Dominate, 0.5)
