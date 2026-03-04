extends RefCounted
class_name AIComboContext

var pawn:CharacterPawn
var target:CharacterPawn
var distance:float

func pushToQueue(_actionID:int, _args:Array = []):
	pawn.combatAI.pushToQueue(_actionID, _args)

func pushDelay(_time:float):
	pawn.combatAI.pushDelay(_time)
