extends TraitBase

func _init() -> void:
	id = Trait.Princess
	compatibilityType = "gift"
	
	personalityChanges = {
		PersonalityStat.Bratty: Vector2(0.0, 1.0),
		PersonalityStat.Dominant: Vector2(-0.3, 0.0),
	}
	values = {
		TraitValue.GiftValue: 0.5,
		TraitValue.GiftReward: 3.0,
	}
	itemTagValue = {
		ItemValueTag.PrincessGift: 1.0,
		ItemValueTag.KinkyClothing: 0.2,
	}

func getName() -> String:
	return "Princess"

func getDescription() -> String:
	return "Wants better gifts, higher affection gain for good gifts"

func proccessSocialInteractionTags(_tags:Dictionary[int, float], _ourPawn:CharacterPawn, _targetPawn:CharacterPawn):
	multTag(_tags, IATag.GiveGift, 0.2) # Pretty much never gives gifts
