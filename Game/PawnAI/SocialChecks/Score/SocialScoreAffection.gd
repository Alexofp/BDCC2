extends SocialCheckBase
class_name SocialScoreAffection

var scoreMult:float = 1.0
var onlyPositive:bool = false
var moodMult:float = 1.0

func _init(_mult:float = 1.0, _onlyPositive:bool = false) -> void:
	scoreMult = _mult
	onlyPositive = _onlyPositive

func getAgreeScore(_score:float) -> float:
	var theAffection:float = socialHandler.getAffection()
	
	var theFinalScore:float = theAffection * scoreMult
	
	theFinalScore += socialHandler.getTargetPawn().mood.effects.affectionShift * moodMult
	
	if(onlyPositive):
		return _score + maxf(0.0, theFinalScore)
	return _score + theFinalScore

func setMoodMult(_mult:float) -> SocialScoreAffection:
	moodMult = _mult
	return self
