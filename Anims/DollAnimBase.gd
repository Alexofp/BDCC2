extends RefCounted
class_name DollAnimBase

const TYPE_GENERIC = 0
const TYPE_IDLE = 1
const TYPE_WALK = 2
const TYPE_ARMS = 3
const TYPE_COMBAT = 4

const LOCOMOTION_ANIMS = "LocomotionAnims"
const LOCOMOTION_ANIMS_PATH = "res://Anims/Raw/LocomotionAnims.glb"

const RESTRAINT_ANIMS = "RestraintAnims"
const RESTRAINT_ANIMS_PATH = "res://Anims/Raw/RestraintAnims.glb"

const ARMBINDERANIMMALE_ANIMS = "ArmbinderAnimMale"
const ARMBINDERANIMMALE_ANIMS_PATH = "res://Anims/Raw/ArmbinderAnimMale.glb"

const GESTURE_ANIMS = "GestureAnims"
const GESTURE_ANIMS_PATH = "res://Anims/Raw/GestureAnims.glb"

const POSES_ANIMS = "Poses"
const POSES_ANIMS_PATH = "res://Anims/Raw/Poses.glb"

const COMBAT_ANIMS = "CombatAnims"
const COMBAT_ANIMS_PATH = "res://Anims/Raw/CombatAnims.glb"

#animPlayer.add_animation_library("RestraintAnims", preload("res://Anims/Raw/RestraintAnims.glb"))
#animPlayer.add_animation_library("ArmbinderAnimMale", preload("res://Anims/Raw/ArmbinderAnimMale.glb"))
#animPlayer.add_animation_library("GestureAnims", preload("res://Anims/Raw/GestureAnims.glb"))

var anims:Dictionary = {
	#"id" = {
		#name = "ASD",
		#anim = "someanim",
	#}
}

#var id:String = ""
#var animVisibleName:String = "FILL ME"

var animType:int = TYPE_GENERIC

#var animName:String = ""
var animLibraryName:String = ""
var animLibraryPath:String = ""

var animCanPick:bool = true
var animSupportsArmPoses:bool = true

var animNameFinal:Dictionary[String, String]
func calcFinalAnimName():
	for _id in anims:
		if(animLibraryName.is_empty()):
			animNameFinal[_id] = anims[_id]["anim"]
		animNameFinal[_id] = animLibraryName+"/"+anims[_id]["anim"]

func getVisibleName(_id:String) -> String:
	if(!anims.has(_id)):
		return "ERROR!"
	return anims[_id].get("name", "MISSING_NAME:"+_id)

func doesAnimSupportArmPoses(_id:String) -> bool:
	return animSupportsArmPoses

const CLOSE_DISTANCE = 1.0

func hasCustomCamera(_id:String) -> bool:
	return false

func processCamera(_id:String, _springLen:float) -> Vector2:
	if(_springLen <= 0.0):
		return Vector2(0.0, 0.0)
	elif(_springLen <= CLOSE_DISTANCE):
		return Vector2(0.1, 1.525)
	return Vector2(0.3, 1.125)
