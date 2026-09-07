@tool
extends SkeletonModifier3D
class_name PenisSkeletonModifier

@export_enum(" ") var lenModificationBone: String:
	set(value):
		lenModificationBone = value
		var skeleton: Skeleton3D = get_skeleton()
		lenModificationBoneID = skeleton.find_bone(lenModificationBone) if skeleton else -1
var lenModificationBoneID:int = -1
@export var chainLength:int = 1
@export var lenModifier:float = 1.0

@export_enum(" ") var ballsBone: String:
	set(value):
		ballsBone = value
		var skeleton: Skeleton3D = get_skeleton()
		ballsBoneID = skeleton.find_bone(ballsBone) if skeleton else -1
var ballsBoneID:int = -1
@export var ballsDrop:float = 0.0
@export var ballsScale:float = 1.0

@export_enum(" ") var scaleBone: String:
	set(value):
		scaleBone = value
		var skeleton: Skeleton3D = get_skeleton()
		scaleBoneID = skeleton.find_bone(scaleBone) if skeleton else -1
var scaleBoneID:int = -1
@export var penisScale:float = 1.0

@export_enum(" ") var scaleBone2: String:
	set(value):
		scaleBone2 = value
		var skeleton: Skeleton3D = get_skeleton()
		scaleBone2ID = skeleton.find_bone(scaleBone2) if skeleton else -1
var scaleBone2ID:int = -1
@export var penisScale2:float = 1.0

func _validate_property(property: Dictionary) -> void:
	if property.name in ["lenModificationBone", "ballsBone", "scaleBone", "scaleBone2"]:
		var skeleton: Skeleton3D = get_skeleton()
		if skeleton:
			property.hint = PROPERTY_HINT_ENUM
			property.hint_string = skeleton.get_concatenated_bone_names()

func _ready() -> void:
	var skeleton: Skeleton3D = get_skeleton()
	if !skeleton:
		return
	lenModificationBoneID = skeleton.find_bone(lenModificationBone)
	ballsBoneID = skeleton.find_bone(ballsBone)
	scaleBoneID = skeleton.find_bone(scaleBone)
	scaleBone2ID = skeleton.find_bone(scaleBone2)
	
func _process_modification_with_delta(_delta: float) -> void:
	var skeleton: Skeleton3D = get_skeleton()
	if !skeleton:
		return # Never happen, but for the safety.
	
	if(lenModificationBoneID >= 0):
		var bone_idx: int = lenModificationBoneID
		var theLen:int = chainLength
		while(theLen > 0):
			var localPosePos:Vector3 = skeleton.get_bone_pose_position(bone_idx)
			localPosePos *= lenModifier
			skeleton.set_bone_pose_position(bone_idx, localPosePos)
			#print(skeleton.get_bone_pose_position(bone_idx))
			
			var parent_idx: int = skeleton.get_bone_parent(bone_idx)
			if(parent_idx < 0):
				break
			bone_idx = parent_idx
			theLen -= 1
	
	if(ballsBoneID >= 0):
		var bone_idx: int = ballsBoneID
		var localPosePos:Vector3 = skeleton.get_bone_pose_position(bone_idx)
		localPosePos.z -= ballsDrop
		skeleton.set_bone_pose_position(bone_idx, localPosePos)
		var localPoseScale:Vector3 = skeleton.get_bone_pose_scale(bone_idx)
		localPoseScale *= max(ballsScale, 0.01)
		skeleton.set_bone_pose_scale(bone_idx, localPoseScale)
	
	if(scaleBoneID >= 0):
		var bone_idx: int = scaleBoneID
		var localPoseScale:Vector3 = skeleton.get_bone_pose_scale(bone_idx)
		localPoseScale *= max(penisScale, 0.01)
		skeleton.set_bone_pose_scale(bone_idx, localPoseScale)
	
	if(scaleBone2ID >= 0):
		var bone_idx: int = scaleBone2ID
		var localPoseScale:Vector3 = skeleton.get_bone_pose_scale(bone_idx)
		localPoseScale *= max(penisScale2, 0.01)
		skeleton.set_bone_pose_scale(bone_idx, localPoseScale)
	
	#localPosePos.y += 0.1
	#skeleton.set_bone_pose_position(bone_idx, localPosePos)
	#print(skeleton.get_bone_pose_position(bone_idx))
	
	#var pose: Transform3D = skeleton.global_transform * skeleton.get_bone_global_pose(bone_idx)
	#print(pose.origin)
