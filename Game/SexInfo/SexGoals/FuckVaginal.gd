extends SexGoalBase

func _init() -> void:
	id = SexGoal.FuckVaginal
	
	fetishesPerformer = [Fetish.SexVaginal]
	fetishesReceiver = []

func isPossibleAtAll(_info:SexParticipantInfo, _sexEngine:SexEngine) -> bool:
	var theChar := _info.getChar()
	if(!theChar.hasReachablePenis()):
		return false
	return true

func isPossible(_info:SexParticipantInfo, _target:SexParticipantInfo, _sex:SexEngine) -> bool:
	var theTarget := _target.getChar()
	if(!theTarget.hasReachableVagina()):
		return false
	
	return false
