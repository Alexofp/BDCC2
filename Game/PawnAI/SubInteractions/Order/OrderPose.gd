extends InteractionSocialBase

#var complimentLines:Array[String]
var dollPoseID:String = ""
var poseType:int = DollPoseBase.PoseType.Fullbody
var poseHandlerType:int = PawnPoseHandler.POSE_IDLE
var normalText:String = "Stand normally"

func saveData() -> Dictionary:
	var _data:Dictionary = super.saveData()
	_data["dollPoseID"] = dollPoseID
	return _data

func loadData(_data:Dictionary):
	super.loadData(_data)
	dollPoseID = SAVE.loadStr(_data, "dollPoseID")

func prepareChanceCalculator():
	setChanceCalculator(SICCAlways.new())

func _init() -> void:
	id = "OrderPose"
	socialActionName = "Change pose"
	socialActionCategory = CATEGORY_ORDER_POSING
	socialFlags = SOCIALFLAG_SHOULD_END_TALKING | SOCIALFLAG_ONLY_IF_TARGET_DOMINATED
	
	registerForInteractionType = [InteractionType.Talking]

func canDoSocialAction(_c:SocialInteractionContext) -> bool:
	#if(!_c.target.submission.isObeyingPawn(_c.main)): # Replaced with social flag
	#	return false
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
		pushDelay()
		pushEvent("setPose", [""])
		pushStopInteraction()
		pushSetState("answer")
	if(_action.id == "say"):
		dollPoseID = _action.args[0]
		var theDollPose:DollPoseBase = GlobalRegistry.getDollPose(dollPoseID)
		#socialInteractionStart()
		refreshDominance(ROLE_TARGET, ROLE_MAIN)
		sayText(ROLE_MAIN, _action.args[0] if !theDollPose else theDollPose.getOrderDialogue())
		pushDelay()
		pushEvent("setPose", [dollPoseID])
		pushStopInteraction()
		pushSetState("answer")

func onQueueEvent(_eventID:String, _args:Array):
	if(_eventID == "setPose"):
		getPawn(ROLE_TARGET).poseHandler.setPoseOf(poseHandlerType, _args[0])
