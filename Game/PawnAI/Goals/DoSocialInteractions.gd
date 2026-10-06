extends AIGoalPawnTarget

#var actionTags:Dictionary[int, float] = {IATag.Friendly: 1.0}
var intent:int = IATag.Friendly
var extraIntent:int = -1
var interactionAmount:int = 3
var didInteractions:Dictionary[String, int]

func _init() -> void:
	id = "DoSocialInteractions"
	handlingInteractions = ["Talking"]
	importantGoal = true
	goalTimeout = 300.0

func setArgs(_args:Array):
	super.setArgs(_args)
	if(_args.size() > 1):
		intent = _args[1]
		#actionTags = _args[1]

func isImpossible() -> bool:
	var thePawn := getTarget()
	if(!thePawn || thePawn.isDefeated() || thePawn.isDoingSex()):
		return true
	if(thePawn.global_position.distance_squared_to(pawn.global_position) > 625.0): # 25 meters
		return true
	if(pawn.isInCombat()):
		return true
	# if no possible actions with the target that satisfy us, abort?
	
	return false

func getScore() -> float:
	return 1.0

func getPlan() -> AIPlan:
	#return makePlan().add("DoSocialInteraction", ["Hug", getTarget(), []])
	return makePlan().add("DoAction", ["TalkStart", getTarget(), []])

func onPlanCompleted(_plan:AIPlan):
	#satisfyGoal()
	pass

func onPlanFail(_plan:AIPlan, _failedAction:AIActionBase, _failStatus:int):
	failGoal()

func processRare(_dt:float):
	pass

func getInteractionActionScoreOverride(_interaction:InteractionBase, _action:InteractionAction, _score:float) -> float:
	if(!isTalkingInteraction(_interaction)):
		return _score
	
	var theScore:float = _score
	var theTags := _action.aiTags
	if(theTags.has(intent)):
		theScore += theTags[intent]
	if(theTags.has(extraIntent)):
		theScore += theTags[extraIntent]
	
	if(_action.id == "startSocial"): # Really devalue interactions that we already did during this goal
		var theInteractionID:String = _action.args[0].id
		if(didInteractions.has(theInteractionID)):
			theScore *= 0.1
	
	#for _tag:int in actionTags:
	#	if(theTags.has(_tag)):
	#		theScore += actionTags[_tag]*theTags[_tag]
	return theScore*_action.chance

func handleInteractionAction(_pawn:CharacterPawn, _interaction:InteractionBase, _action:InteractionAction) -> bool:
	if(_pawn != pawn):
		return false
	#if(isTalkingInteraction(_interaction)):
	#	satisfyGoal()
	#	return true
	
	return false

func isSameAs(_otherGoal:AIGoalBase) -> bool:
	return false

func onInteractionEnd(_interaction:InteractionBase, _role:int):
	if(isTalkingInteraction(_interaction)):
		cancelGoal()
		return
	if(isSocialInteraction(_interaction)):
		var _socialInteraction:InteractionSocialBase = _interaction
		if(_socialInteraction.isFail() || _socialInteraction.isCriticalFail()):
			if(intent != IATag.Mean && intent != IATag.StartFight):
				var _theTarget:CharacterPawn = getTarget()
				var _affection:float = pawn.getAffection(_theTarget)
				
				var possibleTags:Dictionary = {
					intent: maxf(_affection, 0.2),
					IATag.Mean: maxf(1.0 - _affection, 0.1),
					IATag.StartFight: maxf(0.5 - _affection*0.5, 0.1),
				}
				intent = RNG.pickWeightedDict(possibleTags)
		elif(_socialInteraction.isSuccess() || _socialInteraction.isCriticalSuccess()):
			if(RNG.chance(25.0)):
				if(intent == IATag.Lusty):
					extraIntent = IATag.OfferSex
				if(intent == IATag.Domination):
					extraIntent = IATag.Dominate
				if(intent == IATag.Submission):
					extraIntent = IATag.Submit
		
		interactionAmount -= 1
		
		if(!didInteractions.has(_interaction.id)):
			didInteractions[_interaction.id] = 1
		else:
			didInteractions[_interaction.id] += 1
		
		if(interactionAmount <= 0):
			satisfyGoal()
