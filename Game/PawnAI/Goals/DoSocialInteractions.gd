extends AIGoalPawnTarget

var actionTags:Dictionary[int, float] = {IATag.Friendly: 1.0}

func _init() -> void:
	id = "DoSocialInteractions"
	handlingInteractions = ["Talking"]
	importantGoal = true

func setArgs(_args:Array):
	super.setArgs(_args)
	if(_args.size() > 1):
		actionTags = _args[1]

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
	for _tag:int in actionTags:
		if(theTags.has(_tag)):
			theScore += actionTags[_tag]*theTags[_tag]
	#if(isSocialInteraction(_interaction, _action, "Chat")):
	#	return 1.0
	return theScore*_action.chance

func handleInteractionAction(_pawn:CharacterPawn, _interaction:InteractionBase, _action:InteractionAction) -> bool:
	if(_pawn != pawn):
		return false
	if(isTalkingInteraction(_interaction)):
		satisfyGoal()
		return true
	
	#if(isSocialInteraction(_interaction, _action, "Chat")):
	#	satisfyGoal()
	#	return true
	return false
