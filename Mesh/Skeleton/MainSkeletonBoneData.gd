extends RefCounted
class_name MainSkeletonBoneData

const BODY_SKELETON_RAW = preload("res://Mesh/Skeleton/body_skeleton_raw.tscn")

var bones:Array[String] = []
var boneParent:Dictionary[int, int] = {}
var boneChildren:Dictionary[int, PackedInt32Array] = {}
var boneNameToIndx:Dictionary[String, int] = {}

const SkeletonPathPrefix = "rig/Skeleton3D"

var didCalc:bool = false

func doCalc():
	if(didCalc):
		return
	didCalc = true
	var theSkeleton = BODY_SKELETON_RAW.instantiate()
	GlobalRegistry.add_child(theSkeleton)
	theSkeleton.calcSkeletonBones()
	
	bones = theSkeleton.bones
	boneParent = theSkeleton.boneParent
	boneChildren = theSkeleton.boneChildren
	boneNameToIndx = theSkeleton.boneNameToIndx
	theSkeleton.queue_free()
