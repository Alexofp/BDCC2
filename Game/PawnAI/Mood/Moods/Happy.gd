extends MoodBase

func _init() -> void:
	id = "Happy"
	
	if(true):
		var _effects:MoodEffects = MoodEffects.new()
		_effects.friendlyAgreeMod = 0.5
		_effects.sexAgreeMod = 10.0
		addStage(0.0, "Happy", _effects)
	if(true):
		var _effects:MoodEffects = MoodEffects.new()
		_effects.friendlyAgreeMod = 1.0
		_effects.sexAgreeMod = 100.0
		addStage(2.0, "Very happy", _effects)

func calculateScore(_pawn:CharacterPawn, _handler:MoodHandler) -> float:
	if(_handler.mood < 1.0):
		return 0.0
	return _handler.mood
