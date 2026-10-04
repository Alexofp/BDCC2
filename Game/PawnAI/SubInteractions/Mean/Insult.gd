extends InteractionSocialSimpleBase

var meanResponce:String
var calmResponce:String

func _init() -> void:
	id = "Insult"
	socialActionName = "Insult"
	socialActionCategory = CATEGORY_MEAN
	socialIATags = {IATag.Mean: 1.0}
	
	registerForInteractionType = [InteractionType.Talking]
	interactionPriority = PRIO_MEAN + 1.0
	
	startLinesTopic = "Insult"
	startLinesAmount = 4
	startLineFallback = "You are not very bright, are you?"
	startLineTalkGesture = TalkGesture.Angry
	#answerAcceptActionName = "Accept"
	#answerAcceptReaction = "ComplimentAccept"
	#answerAcceptReactionCritical = "ComplimentAccept"
	#answerDenyActionName = "Deny"
	#answerDenyReaction = "ComplimentDeny"
	#answerDenyReactionCritical = "ComplimentDeny"

func prepareChanceCalculator():
	setChanceCalculator(SICCAlways.new().withCritChances(0.1, 0.0))

func onSocialInteractionEnd():
	addSocialExhaustion()
	addRewardAffection(-0.5)
	addMemoryTarget(BadMemories.Insulted)

func onSaidStartLineSimple():
	addAnnoyanceTarget(0.4)

func getAnswersSimple():
	var theMainPawn := getPawn(ROLE_MAIN)
	var theTargetPawn := getPawn(ROLE_TARGET)
	#var agreeScore := scoreSocialAgree()
	
	var theAnnoyance := GM.main.relationshipSystem.getAnnoyancePawns(theTargetPawn, theMainPawn)
	var theAffection := getAffection(ROLE_MAIN, ROLE_TARGET)
	var theMeanScore :float = clampf(-theAffection, 0.1, 1.0)
	
	if(meanResponce.is_empty()):
		meanResponce = getSay(ROLE_TARGET, "InsultResponse", ROLE_MAIN)
	if(calmResponce.is_empty()):
		calmResponce = getSay(ROLE_TARGET, "InsultResponseOuch", ROLE_MAIN)
	
	addAction(action("mean", meanResponce, theMeanScore))
	addAction(action("calm", calmResponce, 1.0-theMeanScore))
	if(canStartFight(ROLE_TARGET, ROLE_MAIN)):
		addAction(action("fight", "*Start Fight*", theAnnoyance*2.0))

func onAnswerSimple(_id:String, _role:int, _action:InteractionAction):
	if _id == "mean":
		socialInteractionAgree()
		sayText(ROLE_TARGET, _action.actionName)
		pushDelay()
		pushSocialEnd()
		pushStopInteraction()
	if _id == "calm":
		socialInteractionDeny()
		sayText(ROLE_TARGET, _action.actionName)
		pushDelay()
		pushSocialDenied()
		pushStopInteraction()
	if _id == "fight":
		markInteractionShouldEndTalking()
		addAnnoyanceTarget(1.0)
		getPawn(ROLE_TARGET).combatAI.addEnemy(getPawn(ROLE_MAIN), CombatPawnAI.ENEMY_SOCIAL_INTERACITON)
		getPawn(ROLE_MAIN).combatAI.addEnemy(getPawn(ROLE_TARGET), CombatPawnAI.ENEMY_SOCIAL_INTERACITON)
		say(ROLE_TARGET, "InsultResponseFight", ROLE_MAIN, {}, TalkGesture.None)
		pushDelay(1.0)
		pushSocialDenied()
		pushStopInteraction()
