extends TraitBase

func _init() -> void:
	id = Trait.Gifter
	compatibilityType = "gift"
	
	personalityChanges = {
		PersonalityStat.Mean: Vector2(-1.0, 0.0),
		PersonalityStat.Perceptive: Vector2(-0.3, -0.1),
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
	return "Gifter"

func getDescription() -> String:
	return "Likes to give gifts"

func proccessSocialInteractionTags(_tags:Dictionary[int, float], _ourPawn:CharacterPawn, _targetPawn:CharacterPawn):
	if(_tags.has(IATag.GiveGift)):
		_tags[IATag.GiveGift] = maxf(0.1, _tags[IATag.GiveGift]*5.0)
