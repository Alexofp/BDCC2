extends TraitBase

# Needs an actual effect!

func _init() -> void:
	id = Trait.Helper
	compatibilityType = "help"
	
	personalityChanges = {
		PersonalityStat.Mean: Vector2(-0.3, 0.0),
		PersonalityStat.Brave: Vector2(0.1, 0.2),
	}

func getName() -> String:
	return "Helper"

func getDescription() -> String:
	return "Likes to help people who are helpless rather than take advantage of them"

func proccessSocialInteractionTags(_tags:Dictionary[int, float], _ourPawn:CharacterPawn, _targetPawn:CharacterPawn):
	multTag(_tags, IATag.Helpful, 2.0)
