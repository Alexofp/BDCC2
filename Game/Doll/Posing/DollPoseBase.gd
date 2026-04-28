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
var animLibraryName:String = ""
var orderText:String = ""

var noSprint:bool = false
var walkSpeed:float = 1.0
var walkSupportsArmPose:bool = true
var poseSupportsArmPose:bool = true
var preventsPartialGestures:bool = true
var preventsFullbodyGestures:bool = true

var poseType:int = PoseType.Fullbody

const CRAWL_SPEED = 0.5

func getAnimName() -> String:
	return animName
func getAnimNameOr(_alt:String) -> String:
	if(animName.is_empty()):
		return _alt
	return animName
func getAnimNameFinal() -> String:
	if(animLibraryName.is_empty()):
		return animName
	return animLibraryName+"/"+animName
func getWalkAnimName() -> String:
	return walkAnim
func getWalkAnimNameOr(_alt:String) -> String:
	if(walkAnim.is_empty()):
		return _alt
	return walkAnim

func getName() -> String:
	return visibleName

func getOrderDialogue() -> String:
	if(orderText.is_empty()):
		return visibleName
	return orderText

func preventsSprint() -> bool:
	return noSprint

func getWalkSpeedMult() -> float:
	return walkSpeed

func doesWalkSupportArmPoses() -> bool:
	return walkSupportsArmPose

func doesPoseSupportArmPoses() -> bool:
	return poseSupportsArmPose

func doesPreventPartialGestures() -> bool:
	return preventsPartialGestures
	
func doesPreventFullbodyGestures() -> bool:
	return preventsFullbodyGestures
