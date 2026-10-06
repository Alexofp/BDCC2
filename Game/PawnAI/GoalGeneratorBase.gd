extends RefCounted
class_name GoalGeneratorBase

var id:String = "error"
var pawn:CharacterPawn
var minTime:float = 10.0
var maxTime:float = 30.0
var time:float = 0.0

func shouldApplyTo(_pawn:CharacterPawn) -> bool:
	return true

func onGenGoals():
	pass

func onSeeNewPawn(_pawn:CharacterPawn):
	pass

# Only gets called if we're nearby
func onDefeatingAnotherPawn(_defeatedPawn:CharacterPawn, _weDidLastBlow:bool, _friendlyFight:bool, _cause:DefeatCause):
	pass
	
# Only gets called if we're nearby
func onDefeatedByAnotherPawn(_winnerPawn:CharacterPawn, _theyDidLastBlow:bool, _friendlyFight:bool, _cause:DefeatCause):
	pass

func onInteractionEnd(_interaction:InteractionBase, _role:int):
	pass

func start():
	time = randf_range(minTime, maxTime)

func setPawn(_pawn:CharacterPawn):
	pawn = _pawn
	pawn.onPawnDelete.connect(func():
		pawn = null
	)

func processRare(_dt:float):
	time -= _dt
	if(time <= 0.0):
		time = randf_range(minTime, maxTime)
		onGenGoals()

func addGoal(_id:String, _args:Array = [], _avoidSame:bool = true):
	var theGoal:AIGoalBase = pawn.ai.goalHandler.addGoal(_id, _args, _avoidSame)
	if(theGoal):
		theGoal.goalGenerator = id

func getSeePawns() -> Array[CharacterPawn]:
	return pawn.ai.vision.getSeePawns()

func getSeePawnsNotBusy() -> Array[CharacterPawn]:
	var thePawns := pawn.ai.vision.getSeePawns()
	var result:Array[CharacterPawn] = []
	for thePawn:CharacterPawn in thePawns:
		if(isBusyOther(thePawn)):
			continue
		result.append(thePawn)
	return result

func getCharacter() -> BaseCharacter:
	if(!pawn):
		return null
	return pawn.getCharacter()

func isBusy() -> bool:
	return pawn.isDoingSomething() || pawn.isDominatedByAnyone() || pawn.isDefeated() || pawn.hasInteraction() || pawn.isInCombat() || pawn.isDoingSex()

func isBusyOther(_pawn:CharacterPawn) -> bool:
	return _pawn.isDoingSomething() || _pawn.isDominatedByAnyone() || _pawn.isDefeated() || _pawn.hasInteraction() || _pawn.isInCombat() || _pawn.isDoingSex()

func isBusyOtherExceptDefeated(_pawn:CharacterPawn) -> bool:
	return _pawn.isDoingSomething() || _pawn.isDominatedByAnyone() || _pawn.hasInteraction() || _pawn.isInCombat() || _pawn.isDoingSex()

func setTimerMin(_time:float):
	time = minf(time, _time)

func onOurGoalEnd(_goal:AIGoalBase):
	return
