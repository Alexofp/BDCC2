extends RefCounted
class_name AIGoalHandler

var ai:PawnAI

var goals:Array[AIGoalBase]
var staticGoals:Dictionary[String, AIGoalBase]
var currentGoal:AIGoalBase

var goalGenerators:Array[GoalGeneratorBase]
var goalGeneratorsDict:Dictionary[String, GoalGeneratorBase]

var interactionToGoal:Dictionary[String, Array]

func saveData() -> Dictionary:
	var theGoalStuff:Array[Dictionary] = []
	for theGoal:AIGoalBase in goals:
		if(theGoal.wasDeleted):
			continue
		theGoalStuff.append({
			id = theGoal.id,
			st = theGoal.isStaticGoal(),
			cur = (currentGoal == theGoal),
			data = theGoal.saveData(),
		})
	return {
		goals = theGoalStuff,
	}

func loadData(_data:Dictionary):
	clearGoals()
	addStaticGoals()
	
	var theGoalStuff:Array[Dictionary] = SAVE.loadArrayOfDicts(_data, "goals")
	for theGoalEntry:Dictionary in theGoalStuff:
		var theID:String = SAVE.loadStr(theGoalEntry, "id")
		var _isStatic:bool = SAVE.loadBool(theGoalEntry, "st")
		var _isCur:bool = SAVE.loadBool(theGoalEntry, "cur")
		var theData:Dictionary = SAVE.loadDict(theGoalEntry, "data")
		
		if(_isStatic):
			if(!staticGoals.has(theID)):
				continue
			var theExistingStaticGoal:AIGoalBase = staticGoals[theID]
			theExistingStaticGoal.loadData(theData)
			if(_isCur):
				currentGoal = theExistingStaticGoal
			continue
		
		var newGoal:AIGoalBase = GlobalRegistry.createAIGoal(theID)
		if(!newGoal || newGoal.isStaticGoal()):
			continue
		newGoal.setPawn(ai.getPawn())
		newGoal.loadData(theData)
		if(newGoal.wasDeleted):
			continue
		goals.append(newGoal)
		internal_addGoalToLists(newGoal)
		if(_isCur):
			currentGoal = newGoal
	pass

func setAI(_ai:PawnAI):
	ai = _ai
	goals.clear()
	interactionToGoal.clear()
	goalGenerators.clear()
	goalGeneratorsDict.clear()
	addStaticGoals()
	addGoalGenerators()

func isControlledByAnyPlayer() -> bool:
	return ai.getPawn().isControlledByAnyPlayer()

func addGoal(_goalID:String, _args:Array = [], _checkHasSame:bool = true) -> AIGoalBase:
	#if(ai.getPawn().isControlledByAnyPlayer()):
	#	return null
	
	var newGoal:AIGoalBase = GlobalRegistry.createAIGoal(_goalID)
	if(!newGoal):
		return null
	newGoal.setPawn(ai.getPawn())
	newGoal.setArgs(_args)
	if(_checkHasSame):
		for theCurrentGoal in goals:
			if(theCurrentGoal.isSameAs(newGoal)):
				newGoal.setPawn(null)
				return null
	
	goals.append(newGoal)
	newGoal.startFinal()
	internal_addGoalToLists(newGoal)

	if(!newGoal.isStaticGoal()):
		Log.Print("ADDED NEW GOAL: "+_goalID+" "+str(_args))
	return newGoal

func internal_addGoalToLists(_goal:AIGoalBase):
	if(_goal.isStaticGoal()):
		staticGoals[_goal.id] = _goal
	
	for interactionID in _goal.handlingInteractions:
		if(!interactionToGoal.has(interactionID)):
			var _newAr:Array[AIGoalBase] = [_goal]
			interactionToGoal[interactionID] = _newAr
		else:
			interactionToGoal[interactionID].append(_goal)

func clearGoals():
	for theGoal:AIGoalBase in goals.duplicate():
		removeGoal(theGoal, true)

func removeGoal(_goal:AIGoalBase, _removeStatic:bool = false):
	if(currentGoal == _goal):
		setCurrentGoal(null)
	
	if(!_removeStatic && _goal.isStaticGoal()):
		#Log.Printerr("TRYING TO REMOVE A STATIC GOAL FROM PAWN AI: "+_goal.id)
		return
	if(_goal.isStaticGoal()):
		staticGoals.erase(_goal.id)
	#goals.erase(_goal)
	if(_goal.wasDeleted):
		return
	_goal.wasDeleted = true #Gonna be deleted in the next processRare()
	for interactionID in _goal.handlingInteractions:
		if(!interactionToGoal.has(interactionID)):
			continue
		interactionToGoal[interactionID].erase(_goal)
	
	if(!_goal.goalGenerator.is_empty() && goalGeneratorsDict.has(_goal.goalGenerator)):
		var theGen:GoalGeneratorBase = goalGeneratorsDict[_goal.goalGenerator]
		theGen.onOurGoalEnd(_goal)
	
	Log.Print("REMOVING GOAL: "+_goal.id)

func addStaticGoals():
	for staticGoalRef in GlobalRegistry.getAIGoalsStaticRefs():
		addGoal(staticGoalRef.id)

func addGoalGenerator(_id:String):
	var theGen:GoalGeneratorBase = GlobalRegistry.createGoalGenerator(_id)
	if(!theGen):
		return
	addGoalGeneratorObject(theGen)

func addGoalGeneratorObject(_gen:GoalGeneratorBase):
	if(!_gen.shouldApplyTo(ai.pawn)):
		return
	goalGenerators.append(_gen)
	goalGeneratorsDict[_gen.id] = _gen
	_gen.setPawn(ai.pawn)
	_gen.start()

func addGoalGenerators():
	for _id in GlobalRegistry.getGoalGenerators():
		addGoalGenerator(_id)

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

func isBusy() -> bool:
	if(currentGoal && currentGoal.isImportant()):
		return true
	var _pawn:CharacterPawn = ai.pawn
	return _pawn.isDoingSomething() || _pawn.isDefeated() || _pawn.hasInteraction() || _pawn.isInCombat() || _pawn.isDoingSex()

func processRare(_dt:float):
	if(isControlledByAnyPlayer()):
		setCurrentGoal(null)
		return

	if(!isBusy()):
		for theGen:GoalGeneratorBase in goalGenerators:
			theGen.processRare(_dt)
	
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
		
		if(currentGoalScore <= 0.0):
			newCurrentGoal = null
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

func handleInteractionAction(_pawn:CharacterPawn, _interaction:InteractionBase, _action:InteractionAction) -> bool:
	if(!interactionToGoal.has(_interaction.id)):
		return false
	var theGoals:Array[AIGoalBase] = interactionToGoal[_interaction.id]
	for theGoal in theGoals:
		if(theGoal.handleInteractionAction(_pawn, _interaction, _action)):
			return true
	
	return false

func handleInteractionEvent(_interaction:InteractionBase, _eventID:String, _args:Array) -> bool:
	if(!interactionToGoal.has(_interaction.id)):
		return false
	var theGoals:Array[AIGoalBase] = interactionToGoal[_interaction.id]
	for theGoal in theGoals:
		if(theGoal.handleInteractionEvent(_interaction, _eventID, _args)):
			return true
	#if(currentGoal):
	#	return currentGoal.handleInteractionEvent(_interaction, _eventID, _args)
	return false

func isPlayer() -> bool:
	return ai && ai.pawn && ai.pawn.isControlledByAnyPlayer()

func onSeeNewPawn(_pawn:CharacterPawn):
	if(isPlayer()):
		return
	for theGen:GoalGeneratorBase in goalGenerators:
		theGen.onSeeNewPawn(_pawn)

# Only gets called if we're nearby
func onDefeatingAnotherPawn(_defeatedPawn:CharacterPawn, _weDidLastBlow:bool, _friendlyFight:bool, _cause:DefeatCause):
	if(isPlayer()):
		return
	for theGen:GoalGeneratorBase in goalGenerators:
		theGen.onDefeatingAnotherPawn(_defeatedPawn, _weDidLastBlow, _friendlyFight, _cause)

# Only gets called if we're nearby
func onDefeatedByAnotherPawn(_winnerPawn:CharacterPawn, _theyDidLastBlow:bool, _friendlyFight:bool, _cause:DefeatCause):
	if(isPlayer()):
		return
	for theGen:GoalGeneratorBase in goalGenerators:
		theGen.onDefeatedByAnotherPawn(_winnerPawn, _theyDidLastBlow, _friendlyFight, _cause)

func onInteractionEnd(_interaction:InteractionBase, _role:int):
	if(isPlayer()):
		return
	for theGoal:AIGoalBase in goals:
		theGoal.onInteractionEnd(_interaction, _role)
	for theGen:GoalGeneratorBase in goalGenerators:
		theGen.onInteractionEnd(_interaction, _role)
