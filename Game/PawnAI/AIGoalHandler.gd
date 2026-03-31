extends RefCounted
class_name AIGoalHandler

var ai:PawnAI

var goals:Array[AIGoalBase]
var currentGoal:AIGoalBase

var interactionToGoal:Dictionary[String, Array]

func setAI(_ai:PawnAI):
	ai = _ai
	goals.clear()
	interactionToGoal.clear()
	addStaticGoals()

func addGoal(_goalID:String, _args:Array = []) -> AIGoalBase:
	if(ai.getPawn().isControlledByAnyPlayer()):
		return null
	
	var newGoal:AIGoalBase = GlobalRegistry.createAIGoal(_goalID)
	if(!newGoal):
		return null
	goals.append(newGoal)
	newGoal.setPawn(ai.getPawn())
	newGoal.startFinal(_args)
	for interactionID in newGoal.handlingInteractions:
		if(!interactionToGoal.has(interactionID)):
			var _newAr:Array[AIGoalBase] = [newGoal]
			interactionToGoal[interactionID] = _newAr
		else:
			interactionToGoal[interactionID].append(newGoal)
	if(!newGoal.isStaticGoal()):
		Log.Print("ADDED NEW GOAL: "+_goalID+" "+str(_args))
	return newGoal

func removeGoal(_goal:AIGoalBase):
	if(currentGoal == _goal):
		setCurrentGoal(null)
	
	if(_goal.isStaticGoal()):
		#Log.Printerr("TRYING TO REMOVE A STATIC GOAL FROM PAWN AI: "+_goal.id)
		return
	#goals.erase(_goal)
	if(_goal.wasDeleted):
		return
	_goal.wasDeleted = true #Gonna be deleted in the next processRare()
	for interactionID in _goal.handlingInteractions:
		if(!interactionToGoal.has(interactionID)):
			continue
		interactionToGoal[interactionID].erase(_goal)
	Log.Print("REMOVING GOAL: "+_goal.id)

func addStaticGoals():
	for staticGoalRef in GlobalRegistry.getAIGoalsStaticRefs():
		addGoal(staticGoalRef.id)

func sortGoals():
	goals.sort_custom(func(a:AIGoalBase, b:AIGoalBase): return a.getPriority() > b.getPriority())

func cleanDeletedGoals():
	if(goals.is_empty()):
		return
	var goalAm:int = goals.size()
	for _i in goalAm:
		var _indx:int = goalAm - _i - 1
		if(goals[_indx].wasDeleted):
			goals.remove_at(_indx)
	#goals.filter(func(_el:AIGoalBase): return !_el.wasDeleted)

func processRare(_dt:float):
	sortGoals()
	
	for theGoal in goals:
		if(theGoal.isImpossible()):
			theGoal.stopMe()
			continue
		theGoal.processRareFinal(_dt)
	
	cleanDeletedGoals()
	
	checkCurrentGoal()

func checkCurrentGoal():
	if(currentGoal && !goals.has(currentGoal)):
		setCurrentGoal(null)

	var currentGoalImportant:bool = currentGoal.isImportant() if currentGoal else false
	var currentGoalScore:float = currentGoal.getKeepScore() if currentGoal else 0.0
	
	# If current goal is important, only check the important goals
	if(currentGoalImportant):
		var newCurrentGoal := currentGoal
		
		for theGoal in goals:
			if(!theGoal.isMainGoal() || !theGoal.isImportant()):
				continue
			
			var theNewScore:float = theGoal.getScore()
			if(theNewScore > currentGoalScore || !newCurrentGoal):
				currentGoalScore = theNewScore
				newCurrentGoal = theGoal
		
		setCurrentGoal(newCurrentGoal)
		return

	var possibleGoals:Array[AIGoalBase]
	var possibleGoalsWeights:Array[float]
	var bestImportantGoal:AIGoalBase = null
	var bestImportantGoalScore:float = 0.0
	
	for theGoal in goals:
		if(!theGoal.isMainGoal()):
			continue
		var newGoalScore:float = theGoal.getScore()
		if(newGoalScore <= 0.0):
			continue
		
		if(bestImportantGoal): # Check if the new important goal is better than the current one
			if(!theGoal.isImportant()):
				continue
			if(newGoalScore > bestImportantGoalScore):
				bestImportantGoalScore = newGoalScore
				bestImportantGoal = theGoal
			continue
		
		if(theGoal.isImportant()): # Found an important goal
			bestImportantGoal = theGoal
			bestImportantGoalScore = newGoalScore
			continue
		
		if(newGoalScore > currentGoalScore):
			possibleGoals.append(theGoal)
			possibleGoalsWeights.append(newGoalScore)
		
	if(bestImportantGoal):
		setCurrentGoal(bestImportantGoal)
	elif(!possibleGoals.is_empty()):
		setCurrentGoal(RNG.pickWeighted(possibleGoals, possibleGoalsWeights))
	#else:
	#	setCurrentGoal(null)

func setCurrentGoal(_newGoal:AIGoalBase):
	if(currentGoal == _newGoal):
		return
	currentGoal = _newGoal
	onCurrentGoalSwitch()

func onCurrentGoalSwitch():
	ai.onCurrentAIGoalSwitch()

func getCurrentGoal() -> AIGoalBase:
	return currentGoal

func onPlanCompleted(_plan:AIPlan):
	if(currentGoal):
		currentGoal.onPlanCompleted(_plan)

func onPlanFail(_plan:AIPlan, _failedAction:AIActionBase, _failStatus:int):
	if(currentGoal):
		currentGoal.onPlanFail(_plan, _failedAction, _failStatus)

func getInteractionActionScoreOverride(_interaction:InteractionBase, _action:InteractionAction, _score:float) -> float:
	if(!interactionToGoal.has(_interaction.id)):
		return _score
	for theGoal in interactionToGoal[_interaction.id]:
		_score = theGoal.getInteractionActionScoreOverride(_interaction, _action, _score)
	
	return _score

func handleInteractionAction(_interaction:InteractionBase, _action:InteractionAction) -> bool:
	if(!interactionToGoal.has(_interaction.id)):
		return false
	for theGoal in interactionToGoal[_interaction.id]:
		if(theGoal.handleInteractionAction(_interaction, _action)):
			return true
	
	return false
