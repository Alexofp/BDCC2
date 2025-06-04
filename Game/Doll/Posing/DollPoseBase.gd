extends RefCounted
class_name DollPoseBase

enum PoseType {
	Fullbody,
	Arms,
}

var id:String = ""
var animName:String = ""
var visibleName:String = "Fill me!"
var animLibrary:AnimationLibrary
var animLibraryName:String = ""

var poseType:int = PoseType.Fullbody

const CLOSE_DISTANCE = 1.0

func getAnimName() -> String:
	return animName

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
