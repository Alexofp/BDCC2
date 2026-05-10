extends MoodBase

func _init() -> void:
	id = "Angry"
	
	if(true):
		var _effects:MoodEffects = MoodEffects.new()
		_effects.friendlyAgreeMod = -0.3
		_effects.sexAgreeMod = -10.0
		addStage(0.0, "Angry", _effects)
	if(true):
		var _effects:MoodEffects = MoodEffects.new()
		_effects.friendlyAgreeMod = -1.1
		_effects.sexAgreeMod = -100.0
		addStage(2.0, "Very angry", _effects)

func calculateScore(_pawn:CharacterPawn, _handler:MoodHandler) -> float:
	var theMood:float = _handler.values.anger * (1.0 - 0.7*_handler.personality(PersonalityStat.Mean))
	
	if(theMood < 1.0):
		return 0.0
	return theMood
