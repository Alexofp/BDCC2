extends InteractionSocialBase

var howManyChats:int = 0
var talkTimer:float = 0.0
var mainTurn:bool = true

func _init() -> void:
	id = "Chat"
	socialActionName = "Chat"
	socialActionCategory = CATEGORY_FRIENDLY
	
	registerForInteractionType = [InteractionType.Talking]
	interactionPriority = PRIO_FRIENDLY + 1.0

func prepareChanceCalculator():
	setChanceCalculator(SICCChat.new())

func onSocialInteractionEnd():
	addSocialExhaustion()
	if(isFail()):
		addSocialCooldown(30.0)
	#addRewardLust(0.2)
	#addRewardPowerBalance(0.3)
	if(isCriticalSuccess()):
		addRewardAffection(0.5)
		addMemoryTarget(FriendlyMemories.Chat)
	elif(isSuccess()):
		addRewardAffection(1.15)
		addMemoryTarget(FriendlyMemories.Chat)
	if(isFail()):
		addRewardAffection(-0.05)

func canDoSocialAction(_c:SocialInteractionContext) -> bool:
	return true

func start(_roles:Dictionary, _args:Array):
	startSocialInteraction()
	pushSay(ROLE_MAIN, "WannaChat", ROLE_TARGET)

func _actions(_role:int):
	if(_role == ROLE_TARGET):
		var agreeScore := scoreSocialAgree()
		
		addAction(action("yes", "Yes", agreeScore))
		addAction(action("no", "No", 1.0 - agreeScore))

func _do(_role:int, _action:InteractionAction):
	if(_action.id == "yes"):
		socialInteractionAgree()
		pushSay(ROLE_TARGET, "Sure", ROLE_MAIN)
		doRandomTalk()
		pushSetState("afterTalk")
		#pushStopInteraction()
	if(_action.id == "no"):
		socialInteractionDeny()
		pushSay(ROLE_TARGET, "No", ROLE_MAIN)
		#pushAddAffection(ROLE_MAIN, ROLE_TARGET, -0.1)
		pushSocialDenied()
		pushStopInteraction()

func doRandomTalk():
	var theTalkerRole:int = ROLE_MAIN if mainTurn else ROLE_TARGET
	var theListenerRole:int = ROLE_TARGET if mainTurn else ROLE_MAIN
	
	howManyChats += 1
	socialInteractionStart()
	pushSay(theTalkerRole, "Talk", theListenerRole)
	pushSocialShowSuccess()
	pushDelay(1.0)
	pushSay(theListenerRole, "Talk", theTalkerRole)
	pushDelay(1.0)
	pushSocialEnd()
	pushEvent("afterTalk")

func onQueueEvent(_eventID:String, _args:Array):
	if(_eventID == "afterTalk"):
		startSocialInteraction()
		talkTimer = 0.0
		mainTurn = !mainTurn

func afterTalk_actions(_role:int):
	if(_role == ROLE_TARGET):
		var agreeScore := scoreSocialAgree()
		addAction(action("enough", "Enough chat").setScore(1.0 - agreeScore))
	if(_role == ROLE_MAIN):
		addAction(action("enough", "Enough chat").setScore(howManyChats*0.1))
		
func afterTalk_do(_role:int, _action:InteractionAction):
	if(_action.id == "enough"):
		pushSay(_role, "EnoughChatSocial", ROLE_MAIN if _role == ROLE_TARGET else ROLE_TARGET)
		pushStopInteraction()

func afterTalk_processRare(_dt:float):
	if(!isInteractionQueueEmpty()):
		return
	talkTimer += _dt
	
	if(talkTimer >= 3.0):
		doRandomTalk()
