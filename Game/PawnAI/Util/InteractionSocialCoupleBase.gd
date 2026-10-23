extends InteractionSocialBase
class_name InteractionSocialCoupleBase

var askText:String = "WannaHug"
var coupleAnim:String = "Hug"
var coupleAnimTime:float = 4.0
var coupleAnimReverse:bool = false
var giveUpTimer:int = 0

var lineSure:String = "Sure"
var lineSureCrit:String = ""
var lineNo:String = "No"
var lineNoCrit:String = ""

func saveData() -> Dictionary:
	var _data:Dictionary = super.saveData()
	_data["giveUpTimer"] = giveUpTimer
	return _data

func loadData(_data:Dictionary):
	super.loadData(_data)
	giveUpTimer = SAVE.loadInt(_data, "giveUpTimer")

func _init() -> void:
	id = ""

func getRequiredRoles(_args:Array) -> Dictionary[int, String]:
	return {
		ROLE_MAIN: "main",
		ROLE_TARGET: "target",
	}

func canDoSocialAction(_c:SocialInteractionContext) -> bool:
	if(!_c.main.isStandingOrCanGetUpEasily()):
		return false
	if(!_c.target.isStandingOrCanGetUpEasily()):
		return false
	return true

func start(_roles:Dictionary, _args:Array):
	startSocialInteraction()
	pushSay(ROLE_MAIN, askText, ROLE_TARGET)

func _actions(_role:int):
	if(_role == ROLE_TARGET):
		var agreeScore := scoreSocialAgree()
		addAction(action("base_yes", "Yes", agreeScore))
		addAction(action("base_no", "No", 1.0 - agreeScore))
	if(_role == ROLE_MAIN):
		addAction(action("base_cancel_main", "Cancel talk").setOnTimeout(10.0).setShowAfter(5.0))

func _do(_role:int, _action:InteractionAction):
	if(_action.id == "base_cancel_main"):
		markInteractionShouldEndTalking()
		if(!isObeying(ROLE_MAIN, ROLE_TARGET)):
			say(ROLE_MAIN, "TalkStopWastingTime", ROLE_TARGET)
			addAnnoyanceMain(0.2)
		pushStopInteraction()
	if(_action.id == "base_yes"):
		#setState("chat")
		socialInteractionStart()
		socialInteractionAgree()
		var theLine:String = lineSure
		if(isCriticalSuccess() && !lineSureCrit.is_empty()):
			theLine = lineSureCrit
		pushSay(ROLE_TARGET, theLine, ROLE_MAIN)
		pushSetState("doing")
	if(_action.id == "base_no"):
		socialInteractionStart()
		socialInteractionDeny()
		var theLine:String = lineNo
		if(isCriticalFail() && !lineNoCrit.is_empty()):
			theLine = lineNoCrit
		pushSay(ROLE_TARGET, theLine, ROLE_MAIN)
		pushSocialDenied()
		pushStopInteraction()

func onQueueEvent(_eventID:String, _args:Array):
	if(_eventID == "hug"):
		if(!coupleAnimReverse):
			GM.main.coupleAnimsSystem.start(coupleAnim, getPawn(ROLE_MAIN), getPawn(ROLE_TARGET), true)
		else:
			GM.main.coupleAnimsSystem.start(coupleAnim, getPawn(ROLE_TARGET), getPawn(ROLE_MAIN), true)

func doing_processRare(_dt:float):
	var theMain := getPawn(ROLE_MAIN)
	var theTarget := getPawn(ROLE_TARGET)
	if(theMain.isSittingCanGetUpEasily()):
		theMain.getUpFromSittingOnSomething()
	if(theTarget.isSittingCanGetUpEasily()):
		theTarget.getUpFromSittingOnSomething()
	
	if(isInteractionQueueEmpty()):
		if(checkClose2(ROLE_MAIN, ROLE_TARGET, 2.0) && GM.main.coupleAnimsSystem.canStart(coupleAnim, getPawn(ROLE_MAIN), getPawn(ROLE_TARGET))):
			pushStopLookAt(ROLE_MAIN)
			pushStopLookAt(ROLE_TARGET)
			pushEvent("hug")
			pushDelay(coupleAnimTime*0.5)
			pushSocialEnd()
			pushDelay(coupleAnimTime*0.5)
			pushSetState("canstopanim")
			#pushStopInteraction()
		else:
			giveUpTimer += 1
			if(giveUpTimer > 7):
				stopInteraction()

func doing_plan(_role:int, _action:AIActionBase) -> AIPlan:
	return planApproachEachOther(ROLE_MAIN, ROLE_TARGET, _role, _action)
	
#func plan(_role:int, _action:AIActionBase) -> AIPlan:
#	return planFaceEachOther(ROLE_MAIN, ROLE_TARGET, _role, _action)

func canstopanim_actions(_role:int):
	var _hasPlayer:bool = false
	if(isPlayer(ROLE_MAIN) || isPlayer(ROLE_TARGET)):
		_hasPlayer = true
	if(_role == ROLE_TARGET):
		addAction(action("stop_anim", "Stop interaction").allowDuringCoupleAnim().setScore(0.0 if _hasPlayer else 1.0))
	if(_role == ROLE_MAIN):
		addAction(action("stop_anim", "Stop interaction").allowDuringCoupleAnim().setScore(0.0 if _hasPlayer else 1.0))

func canstopanim_do(_role:int, _action:InteractionAction):
	if(_action.id == "stop_anim"):
		GM.main.coupleAnimsSystem.stopFor(getPawn(ROLE_MAIN), false)
		pushDelay(0.3)
		pushStopInteraction()

func canstopanim_processRare(_dt:float):
	if(!GM.main.coupleAnimsSystem.isPairDoingAnyAnim(getPawn(ROLE_MAIN), getPawn(ROLE_TARGET))):
		stopInteraction()
		return

func onEnd():
	super.onEnd()
	var _pawnMain := getPawn(ROLE_MAIN)
	var _pawnTarget := getPawn(ROLE_TARGET)
	if(!_pawnMain || !_pawnTarget):
		return
	if(!GM.main.coupleAnimsSystem.isPairDoingAnyAnim(_pawnMain, _pawnTarget)):
		GM.main.coupleAnimsSystem.stopFor(_pawnMain)
