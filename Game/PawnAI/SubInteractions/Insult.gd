extends InteractionSocialBase

var insultLines: Array[String]

func _init() -> void:
	id = "Insult"
	socialActionName = "Insult"
	socialActionCategory = CATEGORY_MEAN
	
	registerForInteractionType = [InteractionType.Talking]
	interactionPriority = PRIO_MEAN + 1.0

func prepareSocialInteraction():
	addSocial(SocialCheckExhaustion.new())
	addSocial(SocialCheckCooldown.new(SocialCooldown.Insult))
	
	addSocial(SocialEffectAddExhaustion.new())
	addSocial(SocialEffectAddAffection.new(-0.5, -0.2))
	addSocial(SocialEffectAddMemory.new(BadMemories.Insulted))
	
func canDoSocialAction(_c:SocialInteractionContext) -> bool:
	return true

func start(_roles: Dictionary, _args: Array):
	startSocialInteraction()
	insultLines = getXSayLines(4, ROLE_MAIN, "Insult", ROLE_TARGET)
	if insultLines.is_empty():
		insultLines = ["You are not very bright, are you?"]

func _actions(_role: int):
	if _role == ROLE_MAIN:
		for theLine in insultLines:
			addAction(action("say", theLine).setArgs([theLine]).setScore(1.0))

func _do(_role: int, _action: InteractionAction):
	if _action.id == "say":
		socialInteractionStart()
		sayText(ROLE_MAIN, _action.args[0])
		pushDelay(2.0)
		pushSetState("answer")

func answer_actions(_role: int):
	if _role == ROLE_TARGET:
		var theMainPawn := getPawn(ROLE_MAIN)
		var theTargetPawn := getPawn(ROLE_TARGET)
		#var agreeScore := scoreSocialAgree()
		
		var theAnnoyance := GM.main.relationshipSystem.getAnnoyancePawns(theTargetPawn, theMainPawn)
		var theAffection := getAffection(ROLE_MAIN, ROLE_TARGET)
		var theMeanScore :float = clampf(-theAffection, 0.1, 1.0)
		
		addAction(action("mean", getSay(ROLE_TARGET, "InsultResponse", ROLE_MAIN), theMeanScore))
		addAction(action("calm", getSay(ROLE_TARGET, "InsultResponseOuch", ROLE_MAIN), 1.0-theMeanScore))
		if(theTargetPawn.combatAI.canAddEnemy(theMainPawn)):
			addAction(action("fight", "*Start Fight*", theAnnoyance*2.0))

func answer_do(_role: int, _action: InteractionAction):
	if _action.id == "mean":
		#say(ROLE_TARGET, "InsultAccept", ROLE_MAIN)
		sayText(ROLE_TARGET, _action.actionName)
		addAnnoyanceMainTarget(0.3, 0.6)
		pushDelay(2.0)
		pushSocialEnd()
		pushStopInteraction()
	if _action.id == "calm":
		#say(ROLE_TARGET, "InsultDeny", ROLE_MAIN)
		sayText(ROLE_TARGET, _action.actionName)
		addAnnoyanceMainTarget(0.0, 0.3)
		#getPawn(ROLE_TARGET).addAnnoyance(getPawn(ROLE_MAIN), 0.4)
		pushDelay(2.0)
		pushSocialDenied()
		pushStopInteraction()
	if _action.id == "fight":
		socialFlags |= SOCIALFLAG_SHOULD_END_TALKING
		getPawn(ROLE_TARGET).addAnnoyance(getPawn(ROLE_MAIN), 1.0)
		getPawn(ROLE_TARGET).combatAI.addEnemy(getPawn(ROLE_MAIN), CombatPawnAI.ENEMY_SOCIAL_INTERACITON)
		getPawn(ROLE_MAIN).combatAI.addEnemy(getPawn(ROLE_TARGET), CombatPawnAI.ENEMY_SOCIAL_INTERACITON)
		say(ROLE_TARGET, "InsultResponseFight", ROLE_MAIN, {}, false)
		pushDelay(1.0)
		pushSocialDenied()
		pushStopInteraction()
