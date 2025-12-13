extends Node3D

# Used to get a list of bones for the bone filter

@onready var skeleton_3d: Skeleton3D = %Skeleton3D

var bones:Array[String] = []
var boneParent:Dictionary[int, int] = {}
var boneChildren:Dictionary[int, PackedInt32Array] = {}
var boneNameToIndx:Dictionary[String, int] = {}

func getSkeleton() -> Skeleton3D:
	return skeleton_3d

func calcSkeletonBones():
	bones.clear()
	boneParent.clear()
	boneChildren.clear()
	boneNameToIndx.clear()
	
	for _indx in skeleton_3d.get_bone_count():
		var theBoneName:String = skeleton_3d.get_bone_name(_indx)
		bones.append(theBoneName)
		boneNameToIndx[theBoneName] = _indx
		
		var theParentIndx:int = skeleton_3d.get_bone_parent(_indx)
		if(theParentIndx >= 0):
			boneParent[_indx] = theParentIndx
		
		boneChildren[_indx] = skeleton_3d.get_bone_children(_indx)
