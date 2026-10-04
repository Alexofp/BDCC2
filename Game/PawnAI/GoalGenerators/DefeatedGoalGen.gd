extends GoalGeneratorBase

func _init() -> void:
	id = "DefeatedGoalGen"
	minTime = 10.0
	maxTime = 30.0

func shouldApplyTo(_pawn:CharacterPawn) -> bool:
	return true

func onGenGoals():
	var thePawns := getSeePawns()
	if(thePawns.is_empty()):
		return
	for _pawn:CharacterPawn in thePawns:
		if(!_pawn.isDefeated()):
			continue
		tryAddGoalTo(_pawn)

func onSeeNewPawn(_pawn:CharacterPawn):
	if(!_pawn.isDefeated()):
		return
	tryAddGoalTo(_pawn)

func tryAddGoalTo(_pawn:CharacterPawn) -> bool:
	if(isBusy() || isBusyOtherExceptDefeated(_pawn) || !_pawn.isDefeated()):
		return false
	if(_pawn.hasCooldown(PawnCooldowns.HelpfulInteraction)):
		return false
	addGoal("HelpGetUp", [_pawn])
	_pawn.addCooldown(PawnCooldowns.HelpfulInteraction, 120.0)
	return true
