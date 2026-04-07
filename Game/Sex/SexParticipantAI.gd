extends RefCounted
class_name SexParticipantAI

var info:WeakRef

var ticker:float = 0.0

var lust:float = 0.0 # How much does this person enjoy it

var anger:float = 0.0 # Dom only

var resistance:float = 0.0 #Sub only
var fear:float = 0.0 # Sub only

var timerLastStimulation:float = 0.0

var goals:Array[SexGoalBase] = []
var goalsGenerated:bool = false
var currentGoal:SexGoalBase # Which goal does this npc currently persue

var tasksByID:Dictionary[String, Array] = {}
var sexTasksByID:Dictionary[String, Array] = {}

var syncState:SyncState = SyncState.new(self,
	["lust", "anger", "resistance", "fear"],
	[Bins.Float, Bins.Float, Bins.Float, Bins.Float],)

func setSyncVar(_var:String, _val:Variant):
	set(_var, _val)
func getSyncVar(_var:String) -> Variant:
	return get(_var)

func onSexStart():
	checkGoals()
	ticker = 1.0 + RNG.randfRange(0.0, 1.0)

func notifyThingHappened():
	ticker = max(RNG.randfRange(1.0, 2.0), ticker)

func notifyThingHappenedNeedsReaction():
	ticker = RNG.randfRange(0.5, 1.0)

func isForced() -> bool:
	return getSexEngine().isForced()

func getArousal() -> float:
	return getChar().getArousal()

func processAI(_dt:float):
	if(!shouldProcessAI()):
		ticker = 1.0
		return
	ticker -= _dt
	if(ticker <= 0.0):
		ticker = RNG.randfRange(0.8, 1.2)
		tickAI()
	
	
	if(isForced()):
		addResistance(_dt*0.05)
	else:
		if(timerLastStimulation > 1.0):
			addResistance(-_dt*0.02)
	
	if(getArousal() <= 0.0 && timerLastStimulation > 5.0):
		addLust(-0.05*_dt)
	
	timerLastStimulation += _dt
	
	syncState.processSyncState(_dt)

func checkCurrentGoal():
	if(currentGoal && !currentGoal.completed):
		return
	if(currentGoal && currentGoal.completed):
		currentGoal = null
	if(goals.is_empty()):
		return
	var possibleGoals:Array[SexGoalBase] = []
	for theGoal in goals:
		if(theGoal.completed):
			continue
		possibleGoals.append(theGoal)
	
	if(!possibleGoals.is_empty()):
		currentGoal = RNG.pick(possibleGoals)

# Main thinking func. Gets called sometimes
func tickAI():
	checkGoals()
	checkCurrentGoal()
	sexTasksByID = calcAllSexTasksByID()
	#tasksByID = calcAllTasksDict()
	
	var theChar := getChar()
	var theID := theChar.getID()
	var theSex := getSexEngine()
	
	if(theSex.isResistMinigameRunning()):
		if(theSex.resistMinigame.isInvolved(theID) && !theSex.resistMinigame.hasResultOf(theID)):
			if(theSex.resistMinigame.state == ResistMinigameNode.STATE_MAIN):
				var theResistMinigame:ResistMinigameNode = theSex.resistMinigame
				var theTarget:float = theResistMinigame.target
				var theTargetTime:float = ResistMinigame.calcTimeFromPos(theTarget)
				theTargetTime += RNG.randfRange(0.05, 0.1) if RNG.chance(50) else -RNG.randfRange(0.05, 0.1)
				var theAIResult:float = ResistMinigame.calcPosFromTime(theTargetTime)
				
				theSex.resistMinigame.pushResult(theID, theAIResult)
			else:
				ticker = 0.2
		return
	
	var theActions := theSex.calculateActions(theID)
	
	var totalScoreSum:float = 0.0
	var possibleActions:Array = []
	for actionEntry in theActions:
		var theScore := calcActionScore(actionEntry)
		if(theScore <= 0.0):
			continue
		totalScoreSum += theScore
		possibleActions.append([actionEntry, theScore])
	
	if(possibleActions.is_empty() || (totalScoreSum < 1.0 && !RNG.chance(totalScoreSum*100.0))):
		return
	
	var pickedAction:Dictionary = RNG.pickWeightedPairs(possibleActions)
	theSex.doAction(theID, pickedAction)

func calcActionScore(_actionEntry:Dictionary) -> float:
	var theSex := getSexEngine()
	var actionID:int = _actionEntry["id"] if _actionEntry.has("id") else -1
	var isTheActionDisabled:bool = _actionEntry["disabled"] if _actionEntry.has("disabled") else false
	if(isTheActionDisabled):
		return 0.0
	var theActivity:SexEngineActivityBase = _actionEntry["activity"] if _actionEntry.has("activity") else null
	var theInfo := getInfo()
	
	if(actionID in [SexEngine.ACTION_CONSENT, SexEngine.ACTION_DENY_CONSENT, SexEngine.ACTION_RESIST]):
		var consentStrategy:int = _actionEntry["consentStrategy"] if _actionEntry.has("consentStrategy") else 0
		var consentArgs:Array = _actionEntry["consentArgs"] if _actionEntry.has("consentArgs") else []
		if(actionID == SexEngine.ACTION_CONSENT):
			return theActivity.calcConsentScore(consentStrategy, consentArgs, theInfo, theSex.isForced())
		else:
			return theActivity.calcNoConsentScore(consentStrategy, consentArgs, theInfo, theSex.isForced())
	elif(actionID == SexEngine.ACTION_SEX_ACTION):
		return _actionEntry["score"] if _actionEntry.has("score") else 0.0
	elif(actionID == SexEngine.ACTION_START_ACTION):
		return _actionEntry["score"] if _actionEntry.has("score") else 0.0
	elif(actionID == SexEngine.ACTION_FORCE):
		return anger*0.2 if anger > 0.5 else 0.0
	
	return 0.0

func generateGoals(_goalAmount:int) -> Array[SexGoalBase]:
	var theSex := getSexEngine()
	var theInfo := getInfo()
	if(!theSex):
		return []
	
	var possibleGoals:Array = []
	#for fetishID in GlobalRegistry.getFetishes():
	#	var goalRefs := GlobalRegistry.getSexGoalRefsForFetishPerforming(fetishID)
	for goalID in GlobalRegistry.getSexGoalRefs():
		var theGoalRef:SexGoalBase = GlobalRegistry.getSexGoalRef(goalID)
		
		var _fetishPerf := theGoalRef.fetishesPerformer
		var _fetishReceiver := theGoalRef.fetishesReceiver
		
		var canUseGoal:bool = false
		for theFetish in _fetishPerf:
			if(fetishDo(theFetish) >= 0.0):
				canUseGoal = true
		for theFetish in _fetishReceiver:
			if(fetishFeel(theFetish) >= 0.0):
				canUseGoal = true
		if(!canUseGoal):
			continue
		
		var allTargetsWithArgs := theGoalRef.getGoalTargets(theInfo, theSex)
		for theTargetEntry in allTargetsWithArgs:
			var theTarget:SexParticipantInfo = theTargetEntry[0]
			var theScore:float = theTargetEntry[1]
			var _theArgs:Array = theTargetEntry[2] if theTargetEntry.size() > 2 else []
			if(theScore <= 0.0):
				continue
			
			var canDoTasksOfThisGoal:bool = false
			theGoalRef.info = theInfo
			theGoalRef.target = theTarget
			var theTasks := theGoalRef.getSexTasks()
			for theTask in theTasks: # At least one goal must be completable
				if(theSex.isSexTaskPossibleToSatisfy(theTask)):
					canDoTasksOfThisGoal = true
					break
			theGoalRef.info = null
			theGoalRef.target = null
			if(!canDoTasksOfThisGoal):
				continue
			
			possibleGoals.append([[theGoalRef, theTarget, _theArgs], theScore])
			
		#var goalEntries := theGoalRef.tryGenerateGoals(theInfo, theSex)
		#for entry in goalEntries:
			#var finalScore:float = entry["score"]
			#
			#if(finalScore <= 0.0):
				#continue
			#possibleGoals.append([ [goalID, entry["args"]], finalScore ])
	
	if(possibleGoals.is_empty()):
		return []
	
	var result:Array[SexGoalBase] = []
	
	while(_goalAmount > 0 && !possibleGoals.is_empty()):
		#var goalEntry:Array = RNG.grabWeightedPairs(possibleGoals)
		var goalEntry:Array = RNG.pickWeightedPairs(possibleGoals)
		
		var theGoal:SexGoalBase = goalEntry[0]
		var theTarget:SexParticipantInfo = goalEntry[1]
		var _theArgs:Array = goalEntry[2]
		
		#var goalID:String = goalEntry[0]
		#var goalArgs:Array = goalEntry[1]
		
		var newGoal := GlobalRegistry.createSexGoal(theGoal.id)
		if(!newGoal):
			continue
		if(!newGoal.setupSexGoal(theInfo, theTarget, theSex, _theArgs)):
			continue
		
		result.append(newGoal)
		Log.Print("GAVE GOAL "+newGoal.id+" TO "+getID()+" TARGET="+theTarget.getID()+" ARGS="+str(_theArgs))
		_goalAmount -= 1
	
	return result

func checkGoals():
	if(goalsGenerated):
		return
	if(!shouldProcessAI()):
		return
	goals = generateGoals(2)
	goalsGenerated = true

func getFinalResistance() -> float:
	return resistance * (1.0 - clamp(fear, 0.0, 1.0)) * (1.0 - clamp(lust, 0.0, 1.0)*0.5)

func getSlightlyResistingScore() -> float:
	if(getFinalResistance() >= 0.2):
		return 1.0
	return 0.0

func getSmoothResistScore() -> float:
	var theFinalResistance := getFinalResistance()
	if(theFinalResistance >= 0.5):
		return 1.0
	if(theFinalResistance <= 0.2):
		return 0.0
	return remap(theFinalResistance, 0.2, 0.5, 0.0, 1.0)

func getResistScore() -> float:
	if(getFinalResistance() >= 0.5):
		return 1.0
	return 0.0

func addAnger(_howMuch:float):
	var theMean:float = personality(PersonalityStat.Mean)
	if(_howMuch > 0.0):
		addAngerRaw(_howMuch * (1.0 + theMean*0.5))
	if(_howMuch < 0.0):
		addAngerRaw(_howMuch * (1.0 - theMean*0.3))

func addResistance(_howMuch:float):
	var theDommy:float = personality(PersonalityStat.Dominant)
	if(_howMuch > 0.0):
		var lustMod:float = (1.0 - lust*0.5)
		addResistanceRaw(_howMuch * lustMod * (1.0 + theDommy*0.2))
	if(_howMuch < 0.0):
		addResistanceRaw(_howMuch * (1.0 - theDommy*0.3))

func addFear(_howMuch:float):
	var theBrave:float = personality(PersonalityStat.Brave)
	if(_howMuch > 0.0):
		addFearRaw(_howMuch * (1.0 - theBrave*0.5))
	if(_howMuch < 0.0):
		addFearRaw(_howMuch * (1.0 + theBrave*0.5))

func addLust(_howMuch:float):
	addLustRaw(_howMuch)

func addAngerRaw(_howMuch:float):
	anger += _howMuch
	anger = clamp(anger, 0.0, 1.0)

func addResistanceRaw(_howMuch:float):
	resistance += _howMuch
	resistance = clamp(resistance, 0.0, 1.0)

func addFearRaw(_howMuch:float):
	fear += _howMuch
	fear = clamp(fear, 0.0, 1.0)

func addLustRaw(_howMuch:float):
	lust += _howMuch
	lust = clamp(lust, 0.0, 1.0)

func personality(_persID:String) -> float:
	var theChar := getChar()
	if(!theChar):
		return 0.0
	return theChar.personality.getStat(_persID)

func fetishDo(_fetishID:String) -> float:
	var theChar := getChar()
	if(!theChar):
		return 0.0
	return theChar.fetishHolder.getPerforming(_fetishID)

func fetishFeel(_fetishID:String) -> float:
	var theChar := getChar()
	if(!theChar):
		return 0.0
	return theChar.fetishHolder.getReceiving(_fetishID)


func isPlayer() -> bool:
	return getChar().isControlledByAnyPlayer()

func shouldProcessAI() -> bool:
	if(isPlayer() && !getInfo().pcAuto):
		return false
	return true

func setParticipant(_info:SexParticipantInfo):
	info = weakref(_info)

func getInfo() -> SexParticipantInfo:
	return info.get_ref() # if info is null, something is really wrong

func getSexEngine() -> SexEngine:
	return getInfo().getSexEngine()

func getChar() -> BaseCharacter:
	return getInfo().getChar()

func isDom() -> bool:
	return getInfo().isDom()

func isSub() -> bool:
	return getInfo().isSub()

func canDoDomActions() -> bool:
	return getInfo().canDoDomActions()

func getID() -> String:
	return getInfo().getID()

func getVisibleAIInfo() -> Array[String]:
	if(!shouldProcessAI()):
		return ["Lust: "+str(int(round(lust*100.0)))+"%",]
	if(canDoDomActions()):
		return [
			"Lust: "+str(int(round(lust*100.0)))+"%",
			"Anger: "+str(int(round(anger*100.0)))+"%",
		]
	else:
		return [
			"Lust: "+str(int(round(lust*100.0)))+"%",
			"Resistance: "+str(int(round(resistance*100.0)))+"%",
			"Fear: "+str(int(round(fear*100.0)))+"%",
		]

func exposeToFetish(_fetishID:String, _intensity:float, _isPerf:bool, _isReceiv:bool):
	if(_isPerf):
		exposeToGenericFetishValue(fetishDo(_fetishID), _intensity)
	if(_isReceiv):
		exposeToGenericFetishValue(fetishFeel(_fetishID), _intensity)

func exposeToGenericFetishValue(myFetishLike:float, _intensity:float):
	timerLastStimulation = 0.0
	if(!isForced()):
		myFetishLike += lust*0.5+getArousal()*0.3
	else:
		myFetishLike -= 0.3
	myFetishLike = Util.unclampValue(myFetishLike, 0.1)
	myFetishLike = clamp(myFetishLike, -1.0, 1.0)
	
	if(myFetishLike > 0.0):
		addLust(_intensity*myFetishLike)
		addResistance(-_intensity)
	if(myFetishLike < 0.0):
		addLust(_intensity*myFetishLike)
		addResistance(-_intensity)

func taskScore(_taskID:String, _charID:String) -> float:
	if(!sexTasksByID.has(_taskID)):
		return 0.0
	var maxScore:float = 0.0
	var theSexTasks:Array[SexTask] = sexTasksByID[_taskID]
	for theSexTask in theSexTasks:
		if(theSexTask.target == _charID):
			maxScore = maxf(maxScore, theSexTask.score)
	return maxScore

func taskScoreReceive(_taskID:String, _charID:String) -> float:
	if(!sexTasksByID.has(_taskID)):
		return 0.0
	var maxScore:float = 0.0
	var theSexTasks:Array[SexTask] = sexTasksByID[_taskID]
	for theSexTask in theSexTasks:
		if(theSexTask.actor == _charID):
			maxScore = maxf(maxScore, theSexTask.score)
	return maxScore

#TODO: DELETE
func taskScoreOLD(_taskID:String, _args:Array) -> float:
	var maxScore:float = 0.0
	
	if(!tasksByID.has(_taskID) || tasksByID[_taskID].is_empty()):
		return 0.0
	
	var theContext:Dictionary = {
		ai = self,
	}
	
	var theTasks:Array = tasksByID[_taskID]
	for taskEntry in theTasks:
		#var _cachedTaskID:String = taskEntry[0]
		#if(_cachedTaskID != _taskID):
		#	continue
		var _cachedTaskArgs:Array = taskEntry[1]
		var _cachedTaskScore:float = taskEntry[2]
		
		var theHandler:SexTaskBase = GlobalRegistry.getSexTaskForTaskID(_taskID)
		if(!theHandler):
			continue
		var newScore:float = theHandler.getActionScore(_args, _taskID, _cachedTaskArgs, theContext)
		newScore *= _cachedTaskScore
		
		if(newScore > maxScore):
			maxScore = newScore
	
	return maxScore

#TODO: DELETE
func calcAllTasks() -> Array:
	var theInfo := getInfo()
	var result:Array = []
	
	for goal in goals:
		if(goal.isCompleted()):
			continue
		var theTasks := goal.getTasks()
		result.append_array(internal_getSubTasksReq(theInfo, theTasks))
		
	return result

func calcAllSexTasksByID() -> Dictionary[String, Array]:
	if(!currentGoal):
		return {}
	
	var _allTasks:Array[SexTask] = []
	
	var theGoalTasks := currentGoal.getSexTasks()
	_allTasks.append_array(theGoalTasks)
	
	internal_getSubSexTasks(theGoalTasks, _allTasks, getSexEngine())
	
	var result:Dictionary[String, Array] = {}
	for theSexTask in _allTasks:
		if(!result.has(theSexTask.id)):
			var theAr:Array[SexTask] = [theSexTask]
			result[theSexTask.id] = theAr
		else:
			result[theSexTask.id].append(theSexTask)
	return result
	
func internal_getSubSexTasks(_checkTasks:Array[SexTask], _allTasks:Array[SexTask], _sexEngine:SexEngine):
	var newTasksToAdd:Array[SexTask] = []
	
	for sexActivityID in GlobalRegistry.getSexActivities():
		var sexActivity:SexEngineActivityBase = GlobalRegistry.getSexActivityRef(sexActivityID)
		if(!sexActivity.isActivitySupported(_sexEngine)):
			continue
		for theSexTask in _checkTasks:
			if(!sexActivity.canDoSexTask(_sexEngine, theSexTask)):
				continue
			newTasksToAdd.append_array(sexActivity.getSubSexTasks(_sexEngine, theSexTask))
		
	if(!newTasksToAdd.is_empty()):
		_allTasks.append_array(newTasksToAdd)
		internal_getSubSexTasks(newTasksToAdd, _allTasks, _sexEngine)
		

#TODO: DELETE
func calcAllTasksDict() -> Dictionary[String, Array]:
	var theInfo := getInfo()
	var _allTasks:Array = []
	var result:Dictionary[String, Array] = {}
	
	for goal in goals:
		if(goal.isCompleted()):
			continue
		var theTasks := goal.getTasks()
		_allTasks.append_array(internal_getSubTasksReq(theInfo, theTasks))
	
	for taskEntry in _allTasks:
		var theID:String = taskEntry[0]
		if(!result.has(theID)):
			result[theID] = [taskEntry]
		else:
			result[theID].append(taskEntry)
	
	return result

#TODO: DELETE
func internal_getSubTasks(theInfo:SexParticipantInfo, _taskID:String, _taskArgs:Array) -> Array:
	var result:Array = []

	# Needs a way to get activities by task?
	for sexActivityID in GlobalRegistry.getSexActivities():
		var sexActivity:SexEngineActivityBase = GlobalRegistry.getSexActivityRef(sexActivityID)
		
		#TODO: add is possible check of some sorts
		var subTasks:Array = sexActivity.getSubTasks(theInfo, _taskID, _taskArgs)
		result.append_array(subTasks)
	
	return result

#TODO: DELETE
func internal_getSubTasksReq(theInfo:SexParticipantInfo, theTasks:Array) -> Array:
	var result:Array = []
	result.append_array(theTasks)
	
	for theTaskEntry in theTasks:
		var _taskID:String = theTaskEntry[0]
		var _taskArgs:Array = theTaskEntry[1]
		#var _taskScore:float = theTaskEntry[2]
		
		var theSubTasks := internal_getSubTasks(theInfo, _taskID, _taskArgs)
		result.append_array(internal_getSubTasksReq(theInfo, theSubTasks))
	
	return result
		
func sendTaskEvent(_taskID:String, _targetInfo:SexParticipantInfo, _event:int):
	for goal in goals:
		if(goal.isCompleted()):
			continue
		if(goal.handleTaskEvent(_taskID, _targetInfo, _event)):
			return

func didCompleteAllGoals() -> bool:
	if(!goalsGenerated):
		return false
	for goal in goals:
		if(!goal.isCompleted()):
			return false
	return true
