extends RefCounted
class_name SoloGoalBase

var id:String = ""

func getScore(_pawn:CharacterPawn) -> float:
	return 0.0

func getKeepScore(_pawn:CharacterPawn) -> float:
	return getScore(_pawn) + 0.1

func canDo(_pawn:CharacterPawn) -> bool:
	return true

func getActions(_pawn:CharacterPawn) -> Array:
	return [
		{
			id = "Wait",
			args = [],
			score = 1.0,
		},
	]

func processRare(_pawn:CharacterPawn):
	tryPickAction(_pawn)

func tryPickAction(_pawn:CharacterPawn) -> bool:
	var theAI:PawnAI = _pawn.getAI()
	if(theAI.isDoingAction()):
		return false
	var theActions := getActions(_pawn)
	if(theActions.is_empty()):
		return false
	var theScores:Array[float] = []
	for actionEntry in theActions:
		theScores.append(max(actionEntry["score"], 0.0) if actionEntry.has("score") else 0.0)
	
	var randomEntry:Dictionary = RNG.pickWeighted(theActions, theScores)
	
	theAI.startAction(randomEntry["id"], randomEntry["args"] if randomEntry.has("args") else [])
	return true
