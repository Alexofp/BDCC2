extends InteractionSocialBase

const DEBUG_SKIP_INTRODUCTION := false # Don't forget to change to false

const INTRODUCTION_NORMAL := "normal"
const INTRODUCTION_FRIENDLY := "friendly"
const INTRODUCTION_MEAN := "mean"
const INTRODUCTION_FLIRTY := "flirty"
const INTRODUCTION_SHY := "shy"
const INTRODUCTION_DOM := "dom"

const INTRO_TO_START_REACTION:Dictionary[String, String] = {
	INTRODUCTION_NORMAL: "IntroduceNormal",
	INTRODUCTION_FRIENDLY: "IntroduceFriendly",
	INTRODUCTION_MEAN: "IntroduceMean",
	INTRODUCTION_FLIRTY: "IntroduceFlirty",
	INTRODUCTION_SHY: "IntroduceShy",
	INTRODUCTION_DOM: "IntroduceDom",
}
const INTRO_TO_REACT_REACTION:Dictionary[String, String] = {
	INTRODUCTION_NORMAL: "IntroReactNormal",
	INTRODUCTION_FRIENDLY: "IntroReactFriendly",
	INTRODUCTION_MEAN: "IntroReactMean",
	INTRODUCTION_FLIRTY: "IntroReactFlirty",
	INTRODUCTION_SHY: "IntroReactShy",
	INTRODUCTION_DOM: "IntroReactDom",
}

func _init() -> void:
	id = "Introduction"
	socialActionName = "Introduction"
	socialActionCategory = CATEGORY_FRIENDLY
	
	socialMustBeIntroduced = false
	
	registerForInteractionType = [InteractionType.VeryImportant]

func canDoSocialAction(_main:CharacterPawn, _target:CharacterPawn) -> bool:
	if(GM.main.relationshipSystem.knows(_main.getID(), _target.getID())):
		return false
	if(_target.submission.isObeyingPawn(_main)):
		return false
	return true

func getSocialActions(_main:CharacterPawn, _target:CharacterPawn) -> Array[InteractionAction]:
	if(DEBUG_SKIP_INTRODUCTION && OS.is_debug_build()):
		return []
	if(!canDoSocialActionFinal(_main, _target)):
		return []
	# Needs a function that calculates which intro should have the biggest score
	return [
		action(id, "Normal introduction").setArgs([INTRODUCTION_NORMAL]).setScore(1.0),
		action(id, "Friendly introduction").setArgs([INTRODUCTION_FRIENDLY]).setScore(1.0),
		action(id, "Mean introduction").setArgs([INTRODUCTION_MEAN]).setScore(1.0),
		action(id, "Flirty introduction").setArgs([INTRODUCTION_FLIRTY]).setScore(1.0),
		action(id, "Shy introduction").setArgs([INTRODUCTION_SHY]).setScore(1.0),
		action(id, "Dominant introduction").setArgs([INTRODUCTION_DOM]).setScore(1.0),
	]

#func prepareSocialInteraction():
	#var theSocial := makeSocialInteraction("GenericFriendly")
	#if(!theSocial):
		#return
	#theSocial.affectionGain = 0.005
	#theSocial.affectionLossDeny = 0.0025
	#theSocial.setKind(SocialInteractionKind.Chat)
	#theSocial.memorySuccess = "Chat"
	#theSocial.memorySuccessAbove = 0.3

func start(_roles:Dictionary, _args:Array):
	#startSocialInteraction()
	var theIntroType:String = _args[0] if _args.size() > 0 else "normal"
	pushSay(ROLE_MAIN, INTRO_TO_START_REACTION.get(theIntroType, "IntroduceNormal"), ROLE_TARGET)
	pushDelay(2.0)

func _actions(_role:int):
	if(_role == ROLE_TARGET):
		#var agreeScore := scoreSocialAgree()
		
		addAction(action(INTRODUCTION_NORMAL, "Normal introduction").setScore(1.0))
		addAction(action(INTRODUCTION_FRIENDLY, "Friendly introduction").setScore(1.0))
		addAction(action(INTRODUCTION_MEAN, "Mean introduction").setScore(1.0))
		addAction(action(INTRODUCTION_FLIRTY, "Flirty introduction").setScore(1.0))
		addAction(action(INTRODUCTION_SHY, "Shy introduction").setScore(1.0))
		addAction(action(INTRODUCTION_DOM, "Dominant introduction").setScore(1.0))
		
		#addAction(action("yes", "Yes", agreeScore))
		#addAction(action("no", "No", 1.0 - agreeScore))

func _do(_role:int, _action:InteractionAction):
	var theIntroType:String = _action.id
	pushSay(ROLE_TARGET, INTRO_TO_REACT_REACTION.get(theIntroType, "IntroduceNormal"), ROLE_MAIN)
	pushDelay(2.0)
	pushStopInteraction()
	GM.main.relationshipSystem.markKnows(getCharID(ROLE_MAIN), getCharID(ROLE_TARGET))
