extends InteractionSocialBase
class_name InteractionSocialCoupleBase

var askText:String = "WannaHug"
var coupleAnim:String = "Hug"
var giveUpTimer:int = 0

var lineSure:String = "Sure"
var lineNo:String = "No"

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
	say(ROLE_MAIN, askText, ROLE_TARGET)
	pushDelay(2.0)

func _actions(_role:int):
	if(_role == ROLE_TARGET):
		var agreeScore := scoreSocialAgree()
		addAction(action("yes", "Yes", agreeScore))
		addAction(action("no", "No", 1.0 - agreeScore))

func _do(_role:int, _action:InteractionAction):
	if(_action.id == "yes"):
		#state = "chat"
		socialInteractionStart()
		say(ROLE_TARGET, lineSure, ROLE_MAIN)
		pushDelay(2.0)
		pushSetState("doing")
	if(_action.id == "no"):
		say(ROLE_TARGET, lineNo, ROLE_MAIN)
		pushDelay(2.0)
		pushSocialDenied()
		pushStopInteraction()

func onQueueEvent(_eventID:String, _args:Array):
	if(_eventID == "hug"):
		GM.main.coupleAnimsSystem.start(coupleAnim, getPawn(ROLE_MAIN), getPawn(ROLE_TARGET))

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
			pushDelay(2.0)
			pushSocialEnd()
			pushDelay(2.0)
			pushStopInteraction()
		else:
			giveUpTimer += 1
			if(giveUpTimer > 7):
				stopInteraction()

func doing_plan(_role:int, _action:AIActionBase) -> AIPlan:
	return planApproachEachOther(ROLE_MAIN, ROLE_TARGET, _role, _action)
	
func plan(_role:int, _action:AIActionBase) -> AIPlan:
	return planFaceEachOther(ROLE_MAIN, ROLE_TARGET, _role, _action)
