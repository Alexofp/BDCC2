extends SexEngineActivityBase
class_name SexTypeBase

func getActivityType() -> int:
	return ACTIVITY_SEXTYPE

func start(_roles:Dictionary, _args:Dictionary):
	setupRoles(_roles, ["dom", "sub"])

func startMainActivity(activityID:String, _roles:Dictionary, _args:Dictionary = {}) -> SexMainActivity:
	var sexEngine:SexEngine = getSexEngine()
	
	return sexEngine.startMainActivity(activityID, _roles, _args)

func onMainActivityEnded(_activityID:String):
	doRun()

func sendEvent(_eventID:String, _args:Array = [], _sendToSelf:bool = true):
	getSexEngine().sendSexTypeEvent(_eventID, _args)
	if(_sendToSelf):
		onEvent(_eventID, _args)

func hasMainActivity() -> bool:
	if(getSexEngine().sexActivity):
		return true
	return false

func shouldAddPickPoseActions(_role:String) -> bool:
	if(hasMainActivity()):
		return false
	return super.shouldAddPickPoseActions(_role)

func canTweakPosition() -> bool:
	return true
	
func addStopSexAction(_role:String, _askWantMore:bool = true):
	var theStopScore := scoreSexStop(_role) if canDoSexDialogues() else 0.0
	var theStopActionScore:float = theStopScore
	
	var theDialogueHandler:SexDialogueHandler = getSexEngine().dialogue
	if(_askWantMore && theStopScore > 0.0 && isRoleAI(_role) && !theDialogueHandler.wantStop):
		var amAsked:int = theDialogueHandler.getAmountStarted("WantMore")
		
		var theAskScoreMult:float = clampf(1.0 - amAsked*amAsked*0.1, 0.0, 1.0)
		var theAskScore:float = theStopActionScore * theAskScoreMult
		if(canDoSexDialogues()):
			addAction(action("Ask want more").do("int_askMore").setScore(theAskScore))
		theStopActionScore -= theAskScore
	addAction(action("Stop").delayCancel(0.5).do("int_stopSex").setScore(theStopActionScore))

func handleStopSexAction(_role:String, _id:String, _roleReactor:String) -> bool:
	if(_id == "int_stopSex"):
		getSexEngine().stopSex()
		return true
	if(_id == "int_askMore"):
		#getSexEngine().stopSex()
		startDialogue("WantMore", _role, _roleReactor)
		return true
	return false

func addStartActivitiesButtons(_role:String):
	var theSex := getSexEngine()
	var theInfo:SexParticipantInfo = getRoleInfo(_role)
	for theSexActivityID in GlobalRegistry.getSexActivities():
		var theActivityRef:SexEngineActivityBase = GlobalRegistry.getSexActivityRef(theSexActivityID)
		if(!theActivityRef.isActivitySupported(theSex)):
			continue
		
		for otherCharID in theSex.participants: #TODO: Replace this with target-based approach
			var otherInfo:SexParticipantInfo = theSex.getInfo(otherCharID)
			
			var theActions := theActivityRef.getStartActionsFinal(theSex, theInfo, otherInfo)
			for actionEntry in theActions:
				addAction(actionEntry)

#func handleStartActivityButtons(_role:String, _id:String, _args:Array) -> bool:
#	return false

func addSexTypeActions(_role:String, _askWantMore:bool = true):
	#if(canDoDomActions(_role)):
	addStartActivitiesButtons(_role)
	
	if(!hasMainActivity()):
		if(canDoDomActions(_role)):
			addStopSexAction(_role, _askWantMore)
