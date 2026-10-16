extends TraitBase

func _init() -> void:
	id = Trait.Extravert
	compatibilityType = "vert"
	
	personalityChanges = {
	}
	values = {
		TraitValue.AffectionGain: 1.1,
		TraitValue.SocialExhaustionGain: 0.6,
		TraitValue.SocialExhaustionDecay: 1.2,
	}

func getName() -> String:
	return "Extravert"

func getDescription() -> String:
	return "Interacts with others more, gains less social exhaustion from interactions."

func processSocialGoalScore(_score:float, _ourPawn:CharacterPawn, _targetPawn:CharacterPawn):
	return _score * 1.5
