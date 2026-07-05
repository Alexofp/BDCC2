extends RefCounted
class_name DollPoseBase

enum PoseType {
	Fullbody,
	Arms,
}

var id:String = ""
var animName:String = ""
var visibleName:String = "Fill me!"
var animLibraryName:String = ""
var orderText:String = ""

var walkAnim:String = ""
#var walkSpeed:float = 1.0

var runAnim:String = ""
#var runSpeed:float = DollController.RUN_MULT_DEFAULT
var noSprint:bool = false

var walkSupportsArmPose:bool = true
var poseSupportsArmPose:bool = true
var preventsPartialGestures:bool = true
var preventsFullbodyGestures:bool = true

var poseType:int = PoseType.Fullbody

var walkModeCrawl:bool = false

func getAnimName(_boundFlags:int = 0) -> String:
	return animName
func getWalkAnimName(_boundFlags:int = 0) -> String:
	if(walkModeCrawl):
		if(_boundFlags & BuffsHolder.BOUND_ARMS):
			return "WalkKneelWalk"
		return "WalkCrawl"
	
	return walkAnim
func getRunAnimName(_boundFlags:int) -> String:
	if(walkModeCrawl):
		if(_boundFlags & BuffsHolder.BOUND_ARMS):
			return "WalkKneelWalkFast"
		return "WalkCrawlFast"
	return runAnim
	
func getName() -> String:
	return visibleName

func getOrderDialogue() -> String:
	if(orderText.is_empty()):
		return visibleName
	return orderText

func preventsSprint() -> bool:
	return noSprint

#func getWalkSpeedMult() -> float:
	#return walkSpeed
#
#func getRunSpeedMult() -> float:
	#return runSpeed

func doesWalkSupportArmPoses() -> bool:
	return walkSupportsArmPose

func doesPoseSupportArmPoses() -> bool:
	return poseSupportsArmPose

func doesPreventPartialGestures() -> bool:
	return preventsPartialGestures
	
func doesPreventFullbodyGestures() -> bool:
	return preventsFullbodyGestures
