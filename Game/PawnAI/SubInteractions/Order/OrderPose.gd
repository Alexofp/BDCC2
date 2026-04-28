extends InteractionSocialBase

#var complimentLines:Array[String]
var dollPoseID:String = ""
var poseType:int = DollPoseBase.PoseType.Fullbody
var poseHandlerType:int = PawnPoseHandler.POSE_IDLE
var normalText:String = "Stand normally"

func _init() -> void:
	id = "OrderPose"
	socialActionName = "Change pose"
	socialActionCategory = CATEGORY_ORDER
	socialShouldEndTalking = true
	
	registerForInteractionType = [InteractionType.Talking]

func prepareSocialInteraction():
	#var theSocial := makeSocialInteraction("GenericFriendly")
	#if(!theSocial):
		#return
	#theSocial.affectionGain = 0.01
	#theSocial.affectionLossDeny = 0.005
	#theSocial.setKind(SocialInteractionKind.Chat)
	#theSocial.memorySuccess = "Compliment"
	#theSocial.memorySuccessAbove = 0.3
	pass
	
func canDoSocialAction(_main:CharacterPawn, _target:CharacterPawn) -> bool:
	if(!_target.submission.isObeyingPawn(_main)):
		return false
	return true

func start(_roles:Dictionary, _args:Array):
	#startSocialInteraction()
	pass

func _actions(_role:int):
	if(_role == ROLE_MAIN):
		var currentIdle:String = getPawn(ROLE_TARGET).poseHandler.getPoseOf(poseHandlerType)
		if(!currentIdle.is_empty()):
			addAction(action("stand", "Normal").setScore(1.0))
		
		for theDollPoseID in GlobalRegistry.getDollPoses():
			var theDollPose:DollPoseBase = GlobalRegistry.getDollPose(theDollPoseID)
			if(theDollPose.poseType != poseType):
				continue
			addAction(action("say", theDollPose.getName()).setArgs([theDollPoseID]).setScore(1.0))

func _do(_role:int, _action:InteractionAction):
	if(_action.id == "stand"):
		dollPoseID = ""
		#socialInteractionStart()
		refreshDominance(ROLE_TARGET, ROLE_MAIN)
		sayText(ROLE_MAIN, normalText)
		pushDelay(2.0)
		pushEvent("setPose", [""])
		pushStopInteraction()
		pushSetState("answer")
	if(_action.id == "say"):
		dollPoseID = _action.args[0]
		var theDollPose:DollPoseBase = GlobalRegistry.getDollPose(dollPoseID)
		#socialInteractionStart()
		refreshDominance(ROLE_TARGET, ROLE_MAIN)
		sayText(ROLE_MAIN, _action.args[0] if !theDollPose else theDollPose.getOrderDialogue())
		pushDelay(2.0)
		pushEvent("setPose", [dollPoseID])
		pushStopInteraction()
		pushSetState("answer")

func onQueueEvent(_eventID:String, _args:Array):
	if(_eventID == "setPose"):
		getPawn(ROLE_TARGET).poseHandler.setPoseOf(poseHandlerType, _args[0])

#func answer_actions(_role:int):
	#if(_role == ROLE_TARGET):
		#var agreeScore := scoreSocialAgree()
		#
		#addAction(action("yes", "Accept", agreeScore))
		#addAction(action("no", "Deny", 1.0 - agreeScore))
#
#func answer_do(_role:int, _action:InteractionAction):
	#if(_action.id == "yes"):
		##socialInteractionStart()
		#say(ROLE_TARGET, "ComplimentAccept", ROLE_MAIN)
		#pushDelay(3.0)
		#pushSocialEnd()
		#pushStopInteraction()
	#if(_action.id == "no"):
		#say(ROLE_TARGET, "ComplimentDeny", ROLE_MAIN)
		#pushDelay(2.0)
		##pushAddAffection(ROLE_MAIN, ROLE_TARGET, -0.1)
		#pushSocialDenied()
		#pushStopInteraction()
