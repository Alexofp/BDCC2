extends GoalGeneratorBase

func _init() -> void:
	id = "SocialGoalGenerator"
	minTime = 10.0
	maxTime = 300.0

func shouldApplyTo(_pawn:CharacterPawn) -> bool:
	return true

func calcTalkScore(_pawn:CharacterPawn) -> float:
	# Should reduce score by a lot if we talked recently
	var theScore:float = 1.0
	theScore += absf(pawn.getAffection(_pawn))*0.3
	theScore += absf(pawn.getLust(_pawn))*0.3
	theScore += absf(pawn.getPowerBalance(_pawn))*0.3
	theScore *= (1.0 - pawn.getSocialExhaustion())
	
	var _theCD:float = pawn.getCooldownForPawn(_pawn, PawnCooldowns.GenericInteraction)
	if(_theCD > 0.0):
		_theCD = clampf(_theCD, 0.0, 300.0) # 10 mins max
		theScore *= maxf((1.0-_theCD/200.0), 0.0)
	
	if(pawn.getAnnoyance(_pawn) > 0.0 || _pawn.getAnnoyance(pawn) > 0.0):
		theScore *= 0.1 # Can still ocassionally bug annoyed pawns

	for theTrait:TraitBase in pawn.getTraits():
		theScore = theTrait.processSocialGoalScore(theScore, pawn, _pawn)
	
	return theScore

func onGenGoals():
	#if(true):
	#	return
	var thePawns := getSeePawnsNotBusy()
	if(thePawns.is_empty()):
		return
	
	var theTotalScore:float = 0.0
	var thePawnsWeighted:Dictionary[CharacterPawn, float] = {}
	for thePawn:CharacterPawn in thePawns:
		var theScore:float = calcTalkScore(thePawn)
		if(theScore > 0.0):
			thePawnsWeighted[thePawn] = theScore
			theTotalScore += theScore
	
	if(theTotalScore < 1.0 && !RNG.chance(theTotalScore*100.0)):
		return
	
	var _tryCount:int = 3
	while(_tryCount > 0 && !thePawnsWeighted.is_empty()):
		var theTargetPawn:CharacterPawn = RNG.grabWeightedDict(thePawnsWeighted)
		if(tryAddTheSocialGoal(theTargetPawn)):
			return
		_tryCount -= 1

#func onSeeNewPawn(_pawn:CharacterPawn):
#	tryAddTheSocialGoal(_pawn)

func onDefeatingAnotherPawn(_defeatedPawn:CharacterPawn, _weDidLastBlow:bool, _friendlyFight:bool, _cause:DefeatCause):
	if(_friendlyFight):
		return
	if(_defeatedPawn.isDominatedByAnyone()):
		return
	addGoal("PunishIfDefeated", [_defeatedPawn])

func tryAddTheSocialGoal(_pawn:CharacterPawn) -> bool:
	if((!pawn.canStartTalkWith(_pawn) && !pawn.isTalkingWithAsStarter(_pawn)) || pawn.isDominatedByAnyone() || _pawn.isDominatedByAnyone()):
		return false
	
	var _affection:float = pawn.getAffection(_pawn)
	var _lust:float = pawn.getLust(_pawn)
	var _powerbalance:float = pawn.getPowerBalance(_pawn)
	
	var _personality:Personality = pawn.getPersonality()
	var _persMean:float = _personality.getStat(PersonalityStat.Mean)
	var _persLibido:float = _personality.getStat(PersonalityStat.Libido)
	var _persDommy:float = _personality.getStat(PersonalityStat.Dominant)

	var _annoy:float = pawn.getAnnoyance(_pawn)
	if(_annoy > 0.0): # Annoyance makes us angy at them
		_affection = -3.0
		_lust *= 0.1
	
	# These should be affected by mood/traits/personality/etc
	var theTagWeights:Dictionary[int, float] = {
		IATag.Friendly: _affection+0.2 - _persMean*0.5,
		IATag.Lusty: _lust + _persLibido,
		IATag.OfferSex: ((_lust*0.3+_persLibido) if _lust >= 1.0 else _lust*0.1),
		IATag.Mean: -_affection+0.1 + _persMean,
		IATag.StartFight: -_affection+0.02 + _persMean,
		IATag.Domination: _powerbalance*0.7+0.03 + _persDommy,
		IATag.Dominate: _powerbalance*0.3+0.01 + _persDommy*0.3,
		IATag.Submission: -_powerbalance*0.7+0.03 - _persDommy,
		IATag.Submit: -_powerbalance*0.3+0.01 - _persDommy*0.3,
	}
	for theTrait:TraitBase in pawn.getTraits():
		theTrait.proccessSocialInteractionTags(theTagWeights, pawn, _pawn)
	
	var thePickedTag:int = RNG.pickWeightedDict(theTagWeights)
	
	var theTags:Dictionary[int, float] = {thePickedTag: 1.0}
	var badScore:float = 0.7
	if(thePickedTag == IATag.Mean || thePickedTag == IATag.StartFight || thePickedTag == IATag.Dominate || thePickedTag == IATag.Submit):
		badScore = 0.1

	var theScore:float = pawn.getSocialInteractionsTotalScoreBasedOnTags(_pawn, theTags)
	
	if(theScore < badScore):
		return false

	#addGoal("DoSocialInteractions", [_pawn, theTags])
	addGoal("DoSocialInteractions", [_pawn, thePickedTag])
	pawn.addCooldownForPawn(_pawn, PawnCooldowns.GenericInteraction, RNG.randfRange(60.0, 300.0))
	return true

#func onOurGoalEnd(_goal:AIGoalBase):
#	if(_goal.id == "DoSocialInteractions"):
#		var theTargetGoal:AIGoalPawnTarget = _goal
#		var theTarget:CharacterPawn = theTargetGoal.getTarget()
#		if(theTarget):
#			tryAddTheSocialGoal(theTarget)
