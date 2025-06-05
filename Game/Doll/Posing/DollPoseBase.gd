extends RefCounted
class_name DollPoseBase

enum PoseType {
	Fullbody,
	Arms,
}

var id:String = ""
var animName:String = ""
var walkAnim:String = ""
var visibleName:String = "Fill me!"
var animLibrary:AnimationLibrary
var animLibraryName:String = ""

var noSprint:bool = false
var walkSpeed:float = 1.0
var walkSupportsArmPose:bool = true
var poseSupportsArmPose:bool = true

var poseType:int = PoseType.Fullbody

const CLOSE_DISTANCE = 1.0
const CRAWL_SPEED = 0.5

func getAnimName() -> String:
	return animName
func getWalkAnimName() -> String:
	return walkAnim

func getName() -> String:
	return visibleName

func hasCustomCamera() -> bool:
	return false

func processCamera(_springLen:float) -> Vector2:
	if(_springLen <= 0.0):
		return Vector2(0.0, 0.0)
	elif(_springLen <= CLOSE_DISTANCE):
		return Vector2(0.1, 1.525)
	return Vector2(0.3, 1.125)

func preventsSprint() -> bool:
	return noSprint

func getWalkSpeedMult() -> float:
	return walkSpeed

func doesWalkSupportArmPoses() -> bool:
	return walkSupportsArmPose

func doesPoseSupportArmPoses() -> bool:
	return poseSupportsArmPose
