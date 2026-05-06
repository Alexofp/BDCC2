extends RefCounted
class_name MoodBase

class MoodStage:
	var name:String = "Fill me"
	var score:float = 0.0
	var effects:MoodEffects

var id:String = ""
var stages:Array[MoodStage] = []

func addStage(_score:float, _name:String, _effects:MoodEffects):
	var newStage:MoodStage = MoodStage.new()
	newStage.score = _score
	newStage.name = _name
	newStage.effects = _effects
	stages.append(newStage)

func getStage(_score:float) -> MoodStage:
	_score = maxf(0.0, _score)
	
	var foundStage:MoodStage = null
	for theStage in stages:
		if(!foundStage || (_score >= theStage.score && theStage.score > foundStage.score)):
			foundStage = theStage
	
	if(!foundStage):
		return null
	return foundStage

func getEffects(_score:float) -> MoodEffects:
	var theStage := getStage(_score)
	if(!theStage):
		return null
	return theStage.effects

func calculateScore(_pawn:CharacterPawn, _handler:MoodHandler) -> float:
	return 0.0
