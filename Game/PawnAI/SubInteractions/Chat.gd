extends InteractionSocialBase

var howManyChats:int = 0
var talkTimer:float = 0.0
var mainTurn:bool = true

func _init() -> void:
	id = "Chat"
	socialActionName = "Chat"
	socialActionCategory = CATEGORY_FRIENDLY
	
	registerForInteractionType = [InteractionType.Talking]

func prepareSocialInteraction():
	addSocial(SocialCheckAffection.new(-3.0).addMod(MoodEffects.FriendlyAgreeMod))
	addSocial(SocialCheckExhaustion.new())
	addSocial(SocialCheckCooldown.new(SocialInteractionKind.Chat))
	
	addSocial(SocialEffectAddExhaustion.new())
	addSocial(SocialEffectAddAffection.new(0.1, -0.05))
	addSocial(SocialEffectAddMemory.new("Chat"))
	addSocial(SocialEffectAddMood.new().addSuccess(MoodStat.Mood, 1.1))

func canDoSocialAction(_main:CharacterPawn, _target:CharacterPawn) -> bool:
	return true

func start(_roles:Dictionary, _args:Array):
	startSocialInteraction()
	say(ROLE_MAIN, "WannaChat", ROLE_TARGET)
	pushDelay(2.0)

func _actions(_role:int):
	if(_role == ROLE_TARGET):
		var agreeScore := scoreSocialAgree()
		
		addAction(action("yes", "Yes", agreeScore))
		addAction(action("no", "No", 1.0 - agreeScore))

func _do(_role:int, _action:InteractionAction):
	if(_action.id == "yes"):
		say(ROLE_TARGET, "Sure", ROLE_MAIN)
		pushDelay(3.0)
		doRandomTalk()
		pushSetState("afterTalk")
		#pushStopInteraction()
	if(_action.id == "no"):
		say(ROLE_TARGET, "No", ROLE_MAIN)
		pushDelay(2.0)
		#pushAddAffection(ROLE_MAIN, ROLE_TARGET, -0.1)
		pushSocialDenied()
		pushStopInteraction()

func doRandomTalk():
	var theTalkerRole:int = ROLE_MAIN if mainTurn else ROLE_TARGET
	var theListenerRole:int = ROLE_TARGET if mainTurn else ROLE_MAIN
	
	howManyChats += 1
	socialInteractionStart()
	pushSay(theTalkerRole, "Talk", theListenerRole)
	pushDelay(3.0)
	pushSocialShowSuccess()
	pushDelay(1.0)
	pushSay(theListenerRole, "Talk", theTalkerRole)
	pushDelay(4.0)
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
		say(_role, "EnoughChatSocial", ROLE_MAIN if _role == ROLE_TARGET else ROLE_TARGET)
		pushDelay(2.0)
		pushStopInteraction()

func afterTalk_processRare(_dt:float):
	if(!isInteractionQueueEmpty()):
		return
	talkTimer += _dt
	
	if(talkTimer >= 3.0):
		doRandomTalk()
