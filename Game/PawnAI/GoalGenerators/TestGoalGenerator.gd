extends GoalGeneratorBase

func _init() -> void:
	id = "TestGoalGenerator"
	minTime = 10.0
	maxTime = 30.0

func shouldApplyTo(_pawn:CharacterPawn) -> bool:
	return true

func onGenGoals():
	#if(true):
	#	return
	var thePawns := getSeePawnsNotBusy()
	if(thePawns.is_empty()):
		return
	# Score each pawn and then do weighted random?
	var theTargetPawn:CharacterPawn = RNG.pick(thePawns)
	tryAddTheSocialGoal(theTargetPawn)

func onSeeNewPawn(_pawn:CharacterPawn):
	tryAddTheSocialGoal(_pawn)

func onDefeatingAnotherPawn(_defeatedPawn:CharacterPawn, _weDidLastBlow:bool, _friendlyFight:bool, _cause:DefeatCause):
	if(_friendlyFight):
		return
	addGoal("PunishIfDefeated", [_defeatedPawn])

func tryAddTheSocialGoal(_pawn:CharacterPawn):
	if(!pawn.canStartTalkWith(_pawn) || pawn.isDominatedByAnyone() || _pawn.isDominatedByAnyone()):
		return

	var theTags:Dictionary[int, float] = {IATag.Friendly: 1.0}
	var badScore:float = 0.7
	if(RNG.chance(50.0)):
		theTags = {IATag.Lusty: 1.0}
	elif(RNG.chance(50.0)):
		theTags = {IATag.Mean: 1.0}
		badScore = 0.0
	elif(RNG.chance(50.0)):
		theTags = {IATag.OfferSex: 1.0}
		badScore = 0.0
	elif(RNG.chance(50.0)):
		theTags = {IATag.StartFight: 1.0}
		badScore = 0.0
		
	var theScore:float = pawn.getSocialInteractionsTotalScoreBasedOnTags(_pawn, theTags)
	
	if(theScore < badScore):
		return
		
	addGoal("DoSocialInteractions", [_pawn, theTags])
