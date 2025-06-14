extends InteractionBase

var goal:SoloGoalBase

func _init() -> void:
	id = "SoloInteraction"

func start(_roles:Dictionary, _args:Array):
	involve(ROLE_MAIN, _roles["main"])

func processRare():
	tryPickNewGoal()
	if(goal):
		goal.processRare(getPawn(ROLE_MAIN))

func tryPickNewGoal() -> bool: 
	var theMinScore:float = 0.0 if !goal else goal.getKeepScore(getPawn(ROLE_MAIN))
	var allGoals := gatherPossibleGoals(theMinScore)
	if(allGoals.is_empty()):
		return false
	allGoals = filterOutUnlikelyGoals(allGoals)
	var theGoalToPick:SoloGoalBase = RNG.pickWeightedDict(allGoals)
	
	var newGoal:SoloGoalBase = GlobalRegistry.createSoloGoal(theGoalToPick.id)
	goal = newGoal
	return true

func gatherPossibleGoals(minScore:float = 0.0) -> Dictionary[SoloGoalBase, float]:
	var result:Dictionary[SoloGoalBase, float] = {}
	var thePawn := getPawn(ROLE_MAIN)
	
	for goalID in GlobalRegistry.getSoloGoalsRefs():
		var theGoal:SoloGoalBase = GlobalRegistry.getSoloGoalRef(goalID)
		
		if(!theGoal.canDo(thePawn)):
			continue
		var theScore:float = theGoal.getScore(thePawn)
		if(theGoal.getScore(thePawn) <= minScore):
			continue
		result[theGoal] = theScore
	return result

func filterOutUnlikelyGoals(theGoals:Dictionary[SoloGoalBase, float], filterGape:float = 0.5) -> Dictionary[SoloGoalBase, float]:
	var result:Dictionary[SoloGoalBase, float] = {}
	
	var maxScore:float = 0.0
	for theGoal in theGoals:
		var theScore:float = theGoals[theGoal]
		if(theScore > maxScore):
			maxScore = theScore
	
	var filterOutScore:float = maxScore * filterGape
	
	for theGoal in theGoals:
		var theScore:float = theGoals[theGoal]
		if(theScore >= filterOutScore):
			result[theGoal] = theScore
	
	return result
