extends VBoxContainer

@onready var full_body_anim_list: HFlowContainer = %FullBodyAnimList
@onready var arm_anim_list: HFlowContainer = %ArmAnimList
@onready var gesture_anim_list: HFlowContainer = %GestureAnimList

var charID:String = ""

func setCharacter(_char:BaseCharacter):
	charID = _char.getID() if _char else ""

func getCharacter() -> BaseCharacter:
	if(charID == ""):
		return null
	return GM.characterRegistry.getCharacter(charID)

func getPawn() -> CharacterPawn:
	if(charID == ""):
		return null
	return GM.pawnRegistry.getPawn(charID)

func _ready() -> void:
	updateAnimList(full_body_anim_list, DollPoseBase.PoseType.Fullbody)
	updateAnimList(arm_anim_list, DollPoseBase.PoseType.Arms)
	updateGestureList(gesture_anim_list)

func updateGestureList(_list:FlowContainer):
	Util.delete_children(_list)
	
	for gestureID in GlobalRegistry.getDollGestures():
		var theDollGesture:DollGestureBase = GlobalRegistry.getDollGesture(gestureID)
		if(!theDollGesture.canBeTriggeredManually):
			continue
		var newButton:Button = Button.new()
		newButton.text = theDollGesture.getName()
		
		_list.add_child(newButton)
		
		newButton.pressed.connect(onPlayGestureButton.bind(gestureID))


func updateAnimList(_list:FlowContainer, dollPoseType:int): #DollPoseBase.PoseType.Fullbody
	Util.delete_children(_list)
	
	for dollPoseID in GlobalRegistry.getDollPoses():
		var theDollPose:DollPoseBase = GlobalRegistry.getDollPose(dollPoseID)
		
		if(dollPoseType >= 0 && dollPoseType != theDollPose.poseType):
			continue
		
		var newButton:Button = Button.new()
		newButton.text = theDollPose.getName()
		
		_list.add_child(newButton)
		
		newButton.pressed.connect(onPlayPoseIdleButton.bind(dollPoseID))

func onPlayGestureButton(_gestureID:String):
	var theChar := getCharacter()
	if(!theChar):
		return
	if(GM.pcDoll):
		GM.pcDoll.playGesture(_gestureID)
		#GM.pcDoll.getDoll().playGesture(_gestureID)

func onPlayPoseIdleButton(_dollPoseID:String):
	var thePawn := getPawn()
	if(!thePawn):
		return
	var theDollPose:DollPoseBase = GlobalRegistry.getDollPose(_dollPoseID)
	if(!theDollPose):
		return
	var theCharOption:int = poseTypeToCharOption(theDollPose.poseType)
	if(thePawn.poseHandler.getPoseOf(theCharOption) != _dollPoseID):
		GM.main.pawn_registry.askSetPoseOf(thePawn, theCharOption, _dollPoseID)
	else:
		GM.main.pawn_registry.askSetPoseOf(thePawn, theCharOption, "")

func _on_stop_all_button_pressed() -> void:
	var thePawn := getPawn()
	if(!thePawn):
		return
	GM.main.pawn_registry.askSetPoseOf(thePawn, PawnPoseHandler.POSE_IDLE, "")
	GM.main.pawn_registry.askSetPoseOf(thePawn, PawnPoseHandler.POSE_ARMS, "")

func poseTypeToCharOption(_poseType:int) -> int:
	if(_poseType == DollPoseBase.PoseType.Fullbody):
		return PawnPoseHandler.POSE_IDLE
	if(_poseType == DollPoseBase.PoseType.Arms):
		return PawnPoseHandler.POSE_ARMS
	return -1
