extends RefCounted
class_name DollAnimBase

const TYPE_GENERIC = 0
const TYPE_IDLE = 1
const TYPE_WALK = 2
const TYPE_ARMS = 3
const TYPE_COMBAT = 4
const TYPE_COUPLE = 5
const TYPE_RUN = 6

const LOCOMOTION_ANIMS = "LocomotionAnims"
const LOCOMOTION_ANIMS_PATH = "res://Anims/Raw/LocomotionAnims.glb"

const RESTRAINT_ANIMS = "RestraintAnims"
const RESTRAINT_ANIMS_PATH = "res://Anims/Raw/RestraintAnims.glb"

const ARMBINDERANIM_ANIMS = "ArmbinderAnim"
const ARMBINDERANIM_ANIMS_PATH = "res://Anims/Raw/ArmbinderAnim.glb"

const ARMBINDERANIMMALE_ANIMS = "ArmbinderAnimMale"
const ARMBINDERANIMMALE_ANIMS_PATH = "res://Anims/Raw/ArmbinderAnimMale.glb"

const GESTURE_ANIMS = "GestureAnims"
const GESTURE_ANIMS_PATH = "res://Anims/Raw/GestureAnims.glb"

const POSES_ANIMS = "Poses"
const POSES_ANIMS_PATH = "res://Anims/Raw/Poses.glb"

const COMBAT_ANIMS = "CombatAnims"
const COMBAT_ANIMS_PATH = "res://Anims/Raw/CombatAnims.glb"

const FRIENDLY_ANIMS = "FriendlyAnims"
const FRIENDLY_ANIMS_PATH = "res://Anims/Raw/FriendlyAnims.glb"

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

const FLAG_BLOCKS_ARM_POSES:int = 1

var animType:int = TYPE_GENERIC

#var animName:String = ""
var animLibraryName:String = ""
var animLibraryPath:String = ""

var animCanPick:bool = false

var flagsForAll:int = 0

var animNameFinal:Dictionary[String, String]
var flagsFinal:Dictionary[String, int]
func calcFinalAnimName():
	for _id in anims:
		if(animLibraryName.is_empty()):
			animNameFinal[_id] = anims[_id]["anim"]
		animNameFinal[_id] = animLibraryName+"/"+anims[_id]["anim"]
		if(anims[_id].has("flags")):
			flagsFinal[_id] = anims[_id]["flags"] | flagsForAll
		else:
			flagsFinal[_id] = flagsForAll

func getVisibleName(_id:String) -> String:
	if(!anims.has(_id)):
		return "ERROR!"
	return anims[_id].get("name", "MISSING_NAME:"+_id)

const CLOSE_DISTANCE = 1.0

func hasCustomCamera(_id:String) -> bool:
	return false

func processCamera(_id:String, _springLen:float) -> Vector2:
	if(_springLen <= 0.0):
		return Vector2(0.0, 0.0)
	elif(_springLen <= CLOSE_DISTANCE):
		return Vector2(0.1, 1.525)
	return Vector2(0.3, 1.125)

func getLookAtMods(_id:String) -> Vector3:
	return Vector3(1.0, 1.0, 1.0)

func getMoveSpeed(_id:String) -> float:
	if(anims.has(_id)):
		return anims[_id].get("moveSpeed", 1.0)
	return 1.0

func getAnimSpeed(_id:String) -> float:
	if(anims.has(_id)):
		return anims[_id].get("animSpeed", 1.0)
	return 1.0

func getAnimFinal(_id:String) -> String:
	if(!animNameFinal.has(_id)):
		return ""
	return animNameFinal[_id]

func getAnimFlags(_id:String) -> int:
	if(!flagsFinal.has(_id)):
		return 0
	return flagsFinal[_id]
