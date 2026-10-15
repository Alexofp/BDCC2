extends TraitBase

func _init() -> void:
	id = Trait.Introvert
	compatibilityType = "vert"
	
	personalityChanges = {
		PersonalityStat.Mean: Vector2(-0.3, -0.1),
	}
	passiveAffectionLossMult = 0.5

func getName() -> String:
	return "Introvert"

func getDescription() -> String:
	return "Interacts less with people they don't know. The passive affection loss is slower."

func processSocialGoalScore(_score:float, _ourPawn:CharacterPawn, _targetPawn:CharacterPawn):
	var _theAffection:float = _ourPawn.getAffection(_targetPawn)
	if(absf(_theAffection) < 0.5):
		return _score*(absf(_theAffection)+0.3)
	return _score
