extends RefCounted
class_name DollAnimBase

const TYPE_GENERIC = 0
const TYPE_IDLE = 1
const TYPE_WALK = 2
const TYPE_ARMS = 3

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

#animPlayer.add_animation_library("RestraintAnims", preload("res://Anims/Raw/RestraintAnims.glb"))
#animPlayer.add_animation_library("ArmbinderAnimMale", preload("res://Anims/Raw/ArmbinderAnimMale.glb"))
#animPlayer.add_animation_library("GestureAnims", preload("res://Anims/Raw/GestureAnims.glb"))

var id:String = ""
var animVisibleName:String = "FILL ME"

var animType:int = TYPE_GENERIC

var animName:String = ""
var animLibraryName:String = ""
var animLibraryPath:String = ""

var animCanPick:bool = true
var animSupportsArmPoses:bool = true

var animNameFinal:String = ""
func calcFinalAnimName():
	if(animLibraryName.is_empty()):
		animNameFinal = animName
	animNameFinal = animLibraryName+"/"+animName

func doesAnimSupportArmPoses() -> bool:
	return animSupportsArmPoses
