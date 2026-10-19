extends TraitBase

# Needs an actual effect!

func _init() -> void:
	id = Trait.Vulpture
	compatibilityType = "help"
	
	personalityChanges = {
		PersonalityStat.Mean: Vector2(0.0, 0.3),
		PersonalityStat.Brave: Vector2(-0.3, 0.1),
	}

func getName() -> String:
	return "Vulpture"

func getDescription() -> String:
	return "Likes to take advantage of helpless people rather than helping them"

func proccessSocialInteractionTags(_tags:Dictionary[int, float], _ourPawn:CharacterPawn, _targetPawn:CharacterPawn):
	multTag(_tags, IATag.StartFight, 0.8)
	multTag(_tags, IATag.Helpful, 0.3)
