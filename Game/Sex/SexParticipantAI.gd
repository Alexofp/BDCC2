extends RefCounted
class_name SexParticipantAI

var info:WeakRef

var ticker:float = 0.0

var lust:float = 0.0 # How much does this person enjoy it

var anger:float = 0.0 # Dom only

var resistance:float = 0.0 #Sub only
var fear:float = 0.0 # Sub only

var timerLastStimulation:float = 0.0

var satisfaction:float = 0.0
var frustration:float = 0.0

var goals:Array[SexGoalBase] = []
var goalsGenerated:bool = false
var currentGoal:SexGoalBase # Which goal does this npc currently persue

var sexTasksByID:Dictionary[String, Array] = {}

var commentTopics:Dictionary[String, Dictionary] #[charID, Dict[TopicID, TimeToComment]]

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
	#if(!shouldProcessAI()):
	#	ticker = 1.0
	#	return
	ticker -= _dt
	if(ticker <= 0.0):
		ticker = RNG.randfRange(0.8, 1.2)
		if(shouldProcessAI()):
			tickAI()
	
	if(isForced()):
		addResistance(_dt*0.05, false)
	else:
		if(timerLastStimulation > 1.0):
			addResistance(-_dt*0.02, false)
	
	if(lust > 1.0):
		addLustRaw(-_dt*0.1)
	if(getArousal() <= 0.0 && timerLastStimulation > 5.0):
		addLust(-0.05*_dt)
		#if(timerLastStimulation > 15.0):
		#	addFrustration(0.01*_dt)
	if(getArousal() > 0.0 && timerLastStimulation > 5.0):
		addFrustration(0.02*_dt)
	
	timerLastStimulation += _dt
	
	if(!commentTopics.is_empty()):
		var toRem:Array[String] = []
		for theCharID in commentTopics:
			var toRemTopic:Array[String] = []
			var theTopicsToTime:Dictionary[String, float] = commentTopics[theCharID]
			for theTopic in theTopicsToTime:
				theTopicsToTime[theTopic] -= _dt
				if(theTopicsToTime[theTopic] <= 0.0):
					toRemTopic.append(theTopic)
			for theTopic in toRemTopic:
				theTopicsToTime.erase(theTopic)
			if(theTopicsToTime.is_empty()):
				toRem.append(theCharID)
		for theCharID in toRem:
			commentTopics.erase(theCharID)
	
	syncState.processSyncState(_dt)

func checkCurrentGoal():
	if(currentGoal && !currentGoal.isFinished()):
		return
	if(currentGoal && currentGoal.isFinished()):
		currentGoal = null
	if(goals.is_empty()):
		return
	var possibleGoals:Array[SexGoalBase] = []
	for theGoal in goals:
		if(theGoal.isFinished()):
			continue
		possibleGoals.append(theGoal)
	
	if(!possibleGoals.is_empty()):
		currentGoal = RNG.pick(possibleGoals)

# Main thinking func. Gets called sometimes
func tickAI():
	checkGoals()
	checkCurrentGoal()
	sexTasksByID = calcAllSexTasksByID()
	
	var theChar := getChar()
	var theID := theChar.getID()
	var theSex := getSexEngine()
	
	if(theSex.isResistMinigameRunning()):
		if(theSex.resistMinigame.isInvolved(theID) && !theSex.resistMinigame.hasResultOf(theID)):
			if(theSex.resistMinigame.state == ResistMinigameNode.STATE_MAIN):
				var _isSub:bool = theSex.resistMinigame.isSub(theID)
				var theGrip:float = theSex.getGripLevel()
				var theMinAdd:float = 0.0
				var theMaxAdd:float = theGrip*0.08
				theMaxAdd += pow(RNG.randfRange(0.0, 0.3), 2.0)
				if(_isSub):
					theMaxAdd *= 2.0
				theMinAdd = theMaxAdd * (0.1 if !theMaxAdd else 0.2)
				
				
				var theResistMinigame:ResistMinigameNode = theSex.resistMinigame
				var theTarget:float = theResistMinigame.target
				var theTargetTime:float = ResistMinigame.calcTimeFromPos(theTarget)
				theTargetTime += RNG.randfRange(theMinAdd, theMaxAdd) if RNG.chance(50) else -RNG.randfRange(theMinAdd, theMaxAdd)
				var theAIResult:float = ResistMinigame.calcPosFromTime(theTargetTime)
				
				theSex.resistMinigame.pushResult(theID, theAIResult)
			else:
				ticker = 0.2
		return
	
	var possibleLines:Array[SexDialogueLine] = []
	var possibleScores:Array[float] = []
	var theDialogueHander := theSex.dialogue
	if(theDialogueHander.canDoDialogue()):
		for theChain in theDialogueHander.chains: # Probably could use a util method?
			for theLine in theChain.currentLines:
				if(theLine.main != getInfo()):
					continue
				possibleLines.append(theLine)
				possibleScores.append(theLine.score)
		if(!possibleLines.is_empty()):
			var randomLine:SexDialogueLine = RNG.pickWeighted(possibleLines, possibleScores)
			theDialogueHander.doAnswer(randomLine, -1)
			return
	
	var _haveImportantDialogues:bool = theSex.dialogue.haveImportantChains()
	var theActions := theSex.calculateActions(theID)
	
	var totalScoreSum:float = 0.0
	var possibleActions:Array = []
	for actionEntry in theActions:
		var theScore := calcActionScore(actionEntry)
		if(theScore <= 0.0):
			continue
		if(_haveImportantDialogues && !actionEntry.canBePickedWhileImportantDialogues()):
			continue
		totalScoreSum += theScore
		possibleActions.append([actionEntry, theScore])
	
	if(possibleActions.is_empty() || (totalScoreSum < 1.0 && !RNG.chance(totalScoreSum*100.0))):
		return
	
	var pickedAction:SexEngineAction = RNG.pickWeightedPairs(possibleActions)
	theSex.doAction(theID, pickedAction)

func calcActionScore(_actionEntry:SexEngineAction) -> float:
	var theSex := getSexEngine()
	var actionID:int = _actionEntry.type
	var isTheActionDisabled:bool = _actionEntry.disabled
	if(isTheActionDisabled):
		return 0.0
	var theActivity:SexEngineActivityBase = _actionEntry.activity
	var theInfo := getInfo()
	
	if(actionID in [SexEngine.ACTION_CONSENT, SexEngine.ACTION_DENY_CONSENT, SexEngine.ACTION_RESIST]):
		var consentStrategy:int = _actionEntry.consentStrategy
		var consentArgs:Array = _actionEntry.consentArgs
		if(actionID == SexEngine.ACTION_CONSENT):
			return theActivity.calcConsentScore(consentStrategy, consentArgs, theInfo, theSex.isForced())
		else:
			return theActivity.calcNoConsentScore(consentStrategy, consentArgs, theInfo, theSex.isForced())
	elif(actionID == SexEngine.ACTION_SEX_ACTION):
		return _actionEntry.getScore()
	elif(actionID == SexEngine.ACTION_FORCE):
		return anger*0.2 if anger > 0.5 else 0.0
	
	return 0.0

func generateGoals(_goalAmount:int) -> Array[SexGoalBase]:
	var theGoals := produceGoals(_goalAmount)
	goals.append_array(theGoals)
	return theGoals

func produceGoals(_goalAmount:int) -> Array[SexGoalBase]:
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
			possibleGoals.erase(goalEntry)
			continue
		if(!newGoal.setupSexGoal(theInfo, theTarget, theSex, _theArgs)):
			possibleGoals.erase(goalEntry)
			continue
		
		result.append(newGoal)
		Log.Print("GAVE GOAL "+newGoal.id+" TO "+getID()+" TARGET="+theTarget.getID()+" ARGS="+str(_theArgs))
		_goalAmount -= 1
	
	return result

func checkGoals():
	if(goalsGenerated):
		var goalAm:int = goals.size()
		for _i:int in goalAm: # Doing it like so in case we decide to start deleting goals at some point
			var _indx:int = goalAm - _i - 1
			var theGoal := goals[_indx]
			if(theGoal.isFinished()):
				continue
			if(!theGoal.isPossibleStill()):
				theGoal.impossibleSelf()
		return
	if(!shouldProcessAI()):
		return
	generateGoals(2)
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

func addAnger(_howMuch:float, _addFrustration:bool = true):
	var theMean:float = personality(PersonalityStat.Mean)
	if(_howMuch > 0.0):
		addAngerRaw(_howMuch * (1.0 + theMean*0.5))
		if(_addFrustration):
			affectSatisfaction(_howMuch*0.1*Util.unclampValue(theMean, 0.5)) # mean characters get satisfaction from getting angry
	if(_howMuch < 0.0):
		addAngerRaw(_howMuch * (1.0 - theMean*0.3))

func getAngerResistScore() -> float:
	return maxf(anger, getSmoothResistScore())

func addResistance(_howMuch:float, _addFrustration:bool = true):
	var theDommy:float = personality(PersonalityStat.Dominant)
	var theBratty:float = personality(PersonalityStat.Bratty)
	if(_howMuch > 0.0):
		var lustMod:float = (1.0 - lust*0.5)
		addResistanceRaw(_howMuch * lustMod * (1.0 + theDommy*0.2))
		if(_addFrustration):
			affectSatisfaction(_howMuch*0.1*Util.unclampValue(theBratty, 0.5)) # bratty characters get satisfaction from resisting
	if(_howMuch < 0.0):
		addResistanceRaw(_howMuch * (1.0 - theDommy*0.3))

func addFear(_howMuch:float):
	var theBrave:float = personality(PersonalityStat.Brave)
	if(_howMuch > 0.0):
		addFearRaw(_howMuch * (1.0 - theBrave*0.5))
	if(_howMuch < 0.0):
		addFearRaw(_howMuch * (1.0 + theBrave*0.5))

func addLust(_howMuch:float, _affectSatisfaction:bool = true):
	addLustRaw(_howMuch)
	if(_affectSatisfaction):
		affectSatisfaction(_howMuch*0.01)

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
	if(_howMuch > 0.0 && lust > 1.0):
		_howMuch /= lust
	lust += _howMuch
	lust = clamp(lust, 0.0, 3.0)

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
		return [
			"Lust: "+str(int(round(lust*100.0)))+"%",
			"S: "+str(Util.roundF(satisfaction, 2)),
			"F: "+str(Util.roundF(frustration, 2)),
			]
	if(canDoDomActions()):
		return [
			"Lust: "+str(int(round(lust*100.0)))+"%",
			"Anger: "+str(int(round(anger*100.0)))+"%",
			"S: "+str(Util.roundF(satisfaction, 2)),
			"F: "+str(Util.roundF(frustration, 2)),
		]
	else:
		return [
			"Lust: "+str(int(round(lust*100.0)))+"%",
			#"Resistance: "+str(int(round(resistance*100.0)))+"%",
			"Res: "+str(int(round(resistance*100.0)))+"%",
			"Fear: "+str(int(round(fear*100.0)))+"%",
			"S: "+str(Util.roundF(satisfaction, 2)),
			"F: "+str(Util.roundF(frustration, 2)),
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
		addResistance(_intensity)

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

func calcAllSexTasksByID() -> Dictionary[String, Array]:
	if(!currentGoal):
		return {}
	var theSexEngine:SexEngine = getSexEngine()
	var theCharID:String = getID()
	
	var _allTasks:Array[SexTask] = []
	
	var theGoalTasks := currentGoal.getSexTasks()
	for theActivity in theSexEngine.getAllActivities():
		if(!theActivity.idToRole.has(theCharID)):
			continue
		theGoalTasks.append_array(theActivity.getSubSexTasksExtra(theActivity.getRoleFromID(theCharID)))
	_allTasks.append_array(theGoalTasks)
	
	internal_getSubSexTasks(theGoalTasks, _allTasks, theSexEngine)
	
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
		
func sendTaskEvent(_taskID:String, _targetInfo:SexParticipantInfo, _event:int):
	for goal in goals:
		if(goal.isFinished()):
			continue
		if(goal.handleTaskEvent(_taskID, _targetInfo, _event)):
			return

## Called when any participant finishes a goal
func onParticipantGoalFinished(_info:SexParticipantInfo, _goal:SexGoalBase):
	var wasSuccess:bool = (_goal.status == SexGoalBase.GOAL_COMPLETED)
	var wasFail:bool = (_goal.status == SexGoalBase.GOAL_FAILED)
	var _winScale:float = 0.0
	if(wasSuccess):
		_winScale = 1.0
	elif(wasFail):
		_winScale = -1.0
	
	# We did it
	if(_info == getInfo()):
		affectSatisfaction(1.0 * _winScale)
	
	# We are the target. We get frustrated if the person succeded while we resist.
	elif(_goal.target == getInfo()):
		var _resisting:bool = resistance >= 0.2 #Sex: Better way to calculate if we should be happy about goals failing/succeeding?
		var _resistingScale:float = -1.0 if _resisting else 1.0
		affectSatisfaction(0.75 * _resistingScale * _winScale)
	
	# We're just a sub
	elif(!_info.canDoDomActions()):
		var _resisting:bool = resistance >= 0.2 #Sex: Better way to calculate if we should be happy about goals failing/succeeding?
		var _resistingScale:float = -1.0 if _resisting else 1.0
		affectSatisfaction(0.25 * _resistingScale * _winScale)
		
func didCompleteAllGoals() -> bool:
	if(!goalsGenerated):
		return false
	for goal in goals:
		if(!goal.isCompleted()):
			return false
	return true

func hasAnyGoalsToDo() -> bool:
	if(!goalsGenerated):
		return true
	for goal in goals:
		if(!goal.isFinished()):
			return true
	return false

func completeCurrentGoal():
	if(!currentGoal || currentGoal.isFinished()):
		return
	currentGoal.completeSelf()

func cancelCurrentGoal():
	if(!currentGoal || currentGoal.isFinished()):
		return
	currentGoal.cancelSelf()

func failCurrentGoal():
	if(!currentGoal || currentGoal.isFinished()):
		return
	currentGoal.failSelf()

func impossibleCurrentGoal():
	if(!currentGoal || currentGoal.isFinished()):
		return
	currentGoal.impossibleSelf()

func onConsentRejection(_deniedByCharID:String, _consentCheck:SexEngineQueueEntry.ConsentCheck):
	if(!shouldProcessAI()):
		return
	#cancelCurrentGoal()
	var theEngine := getSexEngine()
	
	theEngine.dialogue.tryAddChain("WhyReject", getInfo(), theEngine.getParticipant(_deniedByCharID))

func onConsentIgnore(_consentCheck:SexEngineQueueEntry.ConsentCheck):
	if(!shouldProcessAI()):
		return
	var theIDs := _consentCheck.getIDsNoConsent()
	if(!theIDs.is_empty()):
		onConsentRejection(RNG.pick(theIDs), _consentCheck)

func addCommentTopic(_otherCharID:String, _topic:String, _timeToComment:float = 5.0):
	if(!commentTopics.has(_otherCharID)):
		var theDict:Dictionary[String, float] = {_topic:_timeToComment}
		commentTopics[_otherCharID] = theDict
	else:
		commentTopics[_otherCharID][_topic] = _timeToComment

func getCommentTopics(_otherCharID:String) -> Dictionary[String, float]:
	if(!commentTopics.has(_otherCharID)):
		return {}
	return commentTopics[_otherCharID]

func clearCommentTopics():
	commentTopics.clear()

func addSatisfaction(_s:float):
	satisfaction += maxf(0.0, _s)

func addFrustration(_f:float):
	frustration += maxf(0.0, _f)

func affectSatisfaction(_v:float):
	if(_v > 0.0):
		addSatisfaction(_v)
	elif(_v < 0.0):
		addFrustration(_v)

func onOrgasm(_orgasm:SexOrgasmInfo, _causer:SexParticipantInfo):
	addSatisfaction(0.5)

func onOrgasmDenied(_causer:SexParticipantInfo):
	addFrustration(0.5) #Sex: Unless you're into it?

func onActivityResisted(_activity:SexEngineActivityBase, _tasks:Dictionary[String, bool]):
	if(!currentGoal):
		return
	
	var hasOurTask:bool = false
	for taskID in _tasks:
		if(sexTasksByID.has(taskID)):
			hasOurTask = true
			break
	if(!hasOurTask):
		addFrustration(0.2) #Sex: Unless this dom likes it?
		return
	currentGoal.resistedAmount += 1
	
	var theStopChance:float = currentGoal.resistedAmount * 30.0 #Sex: Should depend on personality
	if(!RNG.chance(theStopChance)):
		addFrustration(0.3) #Sex: Unless this dom likes it?
		return
	
	addFrustration(0.5) #Sex: Unless this dom likes it?
	failCurrentGoal()
	
func onSubsResisted():
	if(!currentGoal || !getInfo().canDoDomActions()):
		return
	
	currentGoal.resistedAmount += 1
	
	var theStopChance:float = currentGoal.resistedAmount * 30.0 #Sex: Should depend on personality
	if(!RNG.chance(theStopChance)):
		addFrustration(0.3) #Sex: Unless this dom likes it?
		addAnger(0.3, false)
		if(currentGoal.target && currentGoal.target != currentGoal.info):
			addCommentTopic(currentGoal.target.getID(), SexComment.SubResisted)
		return
	
	if(currentGoal.target && currentGoal.target != currentGoal.info):
		getSexEngine().dialogue.tryAddChain("SubResistedGoal", getInfo(), currentGoal.target)
		addAnger(0.3, false)
	addFrustration(0.5) #Sex: Unless this dom likes it?
	failCurrentGoal()
	
