extends SocialCheckBase
class_name SocialScoreLust

var scoreMult:float = 1.0
var onlyPositive:bool = false

func _init(_mult:float = 1.0, _onlyPositive:bool = false) -> void:
	scoreMult = _mult
	onlyPositive = _onlyPositive

func getAgreeScore(_score:float) -> float:
	var theLust:float = socialHandler.getLust()
	
	if(onlyPositive):
		return _score + maxf(0.0, theLust * scoreMult)
	return _score + theLust * scoreMult
