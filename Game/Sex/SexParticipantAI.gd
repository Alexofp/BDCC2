extends RefCounted
class_name SexParticipantAI

var info:WeakRef

var ticker:float = 0.0

var anger:float = 0.0
var resistance:float = 0.0
var fear:float = 0.0

var goals:Array[SexGoalBase] = []
var goalsGenerated:bool = false

var syncState:SyncState = SyncState.new(self,
	["anger", "resistance", "fear"],
	[Bins.Float, Bins.Float, Bins.Float],)

func onSexStart():
	checkGoals()
	ticker = 1.0

func notifyThingHappened():
	ticker = max(RNG.randfRange(0.4, 0.6), ticker)

func notifyThingHappenedNeedsReaction():
	ticker = RNG.randfRange(0.4, 0.6)

func processAI(_dt:float):
	if(isPlayer()):
		ticker = 1.0
		return
	ticker -= _dt
	if(ticker <= 0.0):
		ticker = RNG.randfRange(0.8, 1.2)
		tickAI()
	
	syncState.processSyncState(_dt)

# Main thinking func. Gets called sometimes
func tickAI():
	checkGoals()
	
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
		return 0.0
	elif(actionID == SexEngine.ACTION_START_ACTION):
		return 0.0
	
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
		
		#TODO: Check if this char has the fetishes
		
		var goalEntries := theGoalRef.tryGenerateGoals(theInfo, theSex)
		for entry in goalEntries:
			var finalScore:float = entry["score"]
			
			if(finalScore <= 0.0):
				continue
			possibleGoals.append([ [goalID, entry["args"]], finalScore ])
	
	if(possibleGoals.is_empty()):
		return []
	
	var result:Array[SexGoalBase] = []
	
	while(_goalAmount > 0 && !possibleGoals.is_empty()):
		var goalEntry:Array = RNG.grabWeightedPairs(possibleGoals)
		var goalID:String = goalEntry[0]
		var goalArgs:Array = goalEntry[1]
		
		var newGoal := GlobalRegistry.createSexGoal(goalID)
		if(!newGoal):
			continue
		newGoal.infoRef = weakref(self)
		if(!newGoal.setupGoal(goalArgs)):
			continue
		result.append(newGoal)
		_goalAmount -= 1
	
	return result

func checkGoals():
	if(goalsGenerated):
		return
	if(isPlayer()):
		return
	goals = generateGoals(2)
	goalsGenerated = true

func getFinalResistance() -> float:
	return resistance * (1.0 - clamp(fear, 0.0, 1.0))

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
		addResistanceRaw(_howMuch * (1.0 + theDommy*0.2))
	if(_howMuch < 0.0):
		addResistanceRaw(_howMuch * (1.0 - theDommy*0.3))

func addFear(_howMuch:float):
	var theBrave:float = personality(PersonalityStat.Brave)
	if(_howMuch > 0.0):
		addFearRaw(_howMuch * (1.0 - theBrave*0.5))
	if(_howMuch < 0.0):
		addFearRaw(_howMuch * (1.0 + theBrave*0.5))

func addAngerRaw(_howMuch:float):
	anger += _howMuch
	anger = clamp(anger, 0.0, 1.0)

func addResistanceRaw(_howMuch:float):
	resistance += _howMuch
	resistance = clamp(resistance, 0.0, 1.0)

func addFearRaw(_howMuch:float):
	fear += _howMuch
	fear = clamp(fear, 0.0, 1.0)

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
	if(isPlayer()):
		return []
	if(canDoDomActions()):
		return [
			"Anger: "+str(int(round(anger*100.0)))+"%",
		]
	else:
		return [
			"Resistance: "+str(int(round(resistance*100.0)))+"%",
			"Fear: "+str(int(round(fear*100.0)))+"%",
		]
