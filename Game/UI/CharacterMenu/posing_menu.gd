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

func _ready() -> void:
	updateAnimList(full_body_anim_list, DollPoseBase.PoseType.Fullbody)
	updateAnimList(arm_anim_list, DollPoseBase.PoseType.Arms)
	updateGestureList(gesture_anim_list)

func updateGestureList(_list:FlowContainer):
	Util.delete_children(_list)
	
	for gestureID in GlobalRegistry.getDollGestures():
		var theDollGesture:DollGestureBase = GlobalRegistry.getDollGesture(gestureID)
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
	#TODO SYNC THIS IN MULTIPLAYER
	if(GM.pcDoll):
		GM.pcDoll.playGesture(_gestureID)
		#GM.pcDoll.getDoll().playGesture(_gestureID)

func onPlayPoseIdleButton(_dollPoseID:String):
	var theChar := getCharacter()
	if(!theChar):
		return
	var theDollPose:DollPoseBase = GlobalRegistry.getDollPose(_dollPoseID)
	if(!theDollPose):
		return
	var theCharOption:String = poseTypeToCharOption(theDollPose.poseType)
	if(theChar.getSyncOptionValue(theCharOption) != _dollPoseID):
		GM.characterRegistry.askCharacterSyncOptionChange(theChar, theCharOption, _dollPoseID)
	else:
		GM.characterRegistry.askCharacterSyncOptionChange(theChar, theCharOption, "")

func _on_stop_all_button_pressed() -> void:
	var theChar := getCharacter()
	if(!theChar):
		return
	GM.characterRegistry.askCharacterSyncOptionChange(theChar, CharOption.idlePose, "")
	GM.characterRegistry.askCharacterSyncOptionChange(theChar, CharOption.poseArms, "")

func poseTypeToCharOption(_poseType:int) -> String:
	if(_poseType == DollPoseBase.PoseType.Fullbody):
		return CharOption.idlePose
	if(_poseType == DollPoseBase.PoseType.Arms):
		return CharOption.poseArms
	return ""
