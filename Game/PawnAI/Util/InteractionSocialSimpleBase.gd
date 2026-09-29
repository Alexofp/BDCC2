extends InteractionSocialBase
class_name InteractionSocialSimpleBase

var startLinesTopic:String = "" #"Compliment"
var startLinesAmount:int = 1
var startLineFallback:String = "You look nice today."
var startLineTalkGesture:int = TalkGesture.Chat

var answerAcceptActionName:String = "Accept"
var answerDenyActionName:String = "Deny"

var answerAcceptReaction:String = "ComplimentAccept"
var answerAcceptReactionCritical:String = "ComplimentAccept"
var answerDenyReaction:String = "ComplimentDeny"
var answerDenyReactionCritical:String = "ComplimentDeny"

var pickedOption:String = ""
var startLines:Array[String]

func _init() -> void:
	id = "ERROR"
	socialActionName = "FILL ME"
	socialActionCategory = CATEGORY_FRIENDLY
	
	registerForInteractionType = [InteractionType.Talking]
	interactionPriority = PRIO_FRIENDLY - 1.0

func prepareChanceCalculator():
	var theSICC := SICCSimple.new()
	#theSICC.setChance(RSValue.Affection, 0.3, -0.2, 0.9, 1.5)
	#theSICC.setChance(RSValue.Lust, 0.0, 0.0, 0.5, 1.0)
	setChanceCalculator(theSICC)

func prepareUnlockConditions():
	#addUnlockCondition(SocialUnlockAffectionCondition.new(0.1))
	pass

func onSocialInteractionEnd():
	addSocialExhaustion()
	addSocialCooldown(600.0)
	if(isCriticalSuccess()):
		addRewardAffection(1.0)
		#addMemoryTarget(FriendlyMemories.Compliment)
	elif(isCriticalFail()):
		addRewardAffection(-0.5)
	elif(isSuccess()):
		addRewardAffection(0.4)
		#addMemoryTarget(FriendlyMemories.Compliment)
	elif(isFail()):
		addRewardAffection(-0.1)

func canDoSocialAction(_c:SocialInteractionContext) -> bool:
	return true

func start(_roles:Dictionary, _args:Array):
	startSocialInteraction()
	startLines = getXSayLines(startLinesAmount, ROLE_MAIN, startLinesTopic, ROLE_TARGET)
	if(startLines.is_empty() && !startLineFallback.is_empty()):
		startLines = [startLineFallback]
	if(startLines.size() == 1):
		doStartWithLine(startLines[0])

func doStartWithLine(_line:String):
	socialInteractionStart()
	sayText(ROLE_MAIN, _line, startLineTalkGesture)
	pushDelay()
	pushEvent("saidLine")
	pushSetState("answer")

func onQueueEvent(_eventID:String, _args:Array):
	if(_eventID == "saidLine"):
		onSaidStartLineSimple()

func onSaidStartLineSimple():
	pass

func _actions(_role:int):
	if(_role == ROLE_MAIN):
		if(startLines.is_empty()):
			startLines = ["Something broke!!!"]
		for theLine:String in startLines:
			addAction(action("base_say", theLine).setArgs([theLine]).setScore(1.0))
	if(_role == ROLE_TARGET):
		addAction(action("base_cancel_annoyed", "Cancel talk").setOnTimeout(10.0).setShowAfter(5.0))

func _do(_role:int, _action:InteractionAction):
	if(_action.id == "base_say"):
		doStartWithLine(_action.args[0])
	if(_action.id == "base_cancel_annoyed"):
		markInteractionShouldEndTalking()
		if(!isObeying(ROLE_TARGET, ROLE_MAIN)):
			say(ROLE_TARGET, "TalkStopWastingTime", ROLE_MAIN)
			addAnnoyanceTarget(0.2)
		pushStopInteraction()

func answer_actions(_role:int):
	if(_role == ROLE_TARGET):
		getAnswersSimple()
	if(_role == ROLE_MAIN):
		addAction(action("base_cancel_main", "Cancel talk").setOnTimeout(10.0).setShowAfter(5.0))

func getAnswersSimple():
	var agreeScore := scoreSocialAgree()
	addAction(action("base_yes", answerAcceptActionName, agreeScore))
	addAction(action("base_no", answerDenyActionName, 1.0 - agreeScore))

func answer_do(_role:int, _action:InteractionAction):
	pickedOption = _action.id
	if(_action.id == "base_cancel_main"):
		markInteractionShouldEndTalking()
		if(!isObeying(ROLE_MAIN, ROLE_TARGET)):
			say(ROLE_MAIN, "TalkStopWastingTime", ROLE_TARGET)
			addAnnoyanceMain(0.2)
		pushStopInteraction()
	elif(_action.id == "base_yes"):
		socialInteractionAgree()
		if(isCritical()):
			pushDelay(1.0)
		pushSay(ROLE_TARGET, answerAcceptReaction if !isCritical() else answerAcceptReactionCritical, ROLE_MAIN)
		pushSocialEnd()
		pushStopInteraction()
	elif(_action.id == "base_no"):
		socialInteractionDeny()
		if(isCritical()):
			pushDelay(1.0)
		pushSay(ROLE_TARGET, answerDenyReaction if !isCritical() else answerDenyReactionCritical, ROLE_MAIN)
		pushSocialEnd()
		pushStopInteraction()
	else:
		onAnswerSimple(_action.id, _role, _action)
	
func onAnswerSimple(_id:String, _role:int, _action:InteractionAction):
	pass
