extends TraitBase

func _init() -> void:
	id = Trait.Extravert
	compatibilityType = "vert"
	
	personalityChanges = {
	}
	socialExhaustionGainMult = 0.6
	socialExhaustionDecayMult = 1.2
	affectionGainMult = 1.1

func getName() -> String:
	return "Extravert"

func getDescription() -> String:
	return "Interacts with others more, gains less social exhaustion from interactions."

func processSocialGoalScore(_score:float, _ourPawn:CharacterPawn, _targetPawn:CharacterPawn):
	return _score * 1.5
