extends SoloGoalBase

func _init() -> void:
	id = "Wander"

func getScore(_pawn:CharacterPawn) -> float:
	return 0.3

func getActions(_pawn:CharacterPawn) -> Array:
	if(GM.pcDoll == null):
		return []
	return [
		{
			id = "GoTo",
			args = [GM.pcDoll.global_position],
			score = 1.0,
		},
		{
			id = "Wait",
			args = [],
			score = 1.0,
		},
	]
