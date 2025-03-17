@tool
extends SkeletonModifier3D
class_name PenisSkeletonModifier

@export_enum(" ") var lenModificationBone: String
@export var chainLength:int = 1
@export var lenModifier:float = 1.0

@export_enum(" ") var ballsBone: String
@export var ballsDrop:float = 0.0
@export var ballsScale:float = 1.0

func _validate_property(property: Dictionary) -> void:
	if property.name in ["lenModificationBone", "ballsBone"]:
		var skeleton: Skeleton3D = get_skeleton()
		if skeleton:
			property.hint = PROPERTY_HINT_ENUM
			property.hint_string = skeleton.get_concatenated_bone_names()

func _process_modification() -> void:
	var skeleton: Skeleton3D = get_skeleton()
	if !skeleton:
		return # Never happen, but for the safety.
	
	if(true):
		var bone_idx: int = skeleton.find_bone(lenModificationBone)
		if(bone_idx >= 0):
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
	
	if(true):
		var bone_idx: int = skeleton.find_bone(ballsBone)
		if(bone_idx >= 0):
			var localPosePos:Vector3 = skeleton.get_bone_pose_position(bone_idx)
			localPosePos.z -= ballsDrop
			skeleton.set_bone_pose_position(bone_idx, localPosePos)
			var localPoseScale:Vector3 = skeleton.get_bone_pose_scale(bone_idx)
			localPoseScale *= max(ballsScale, 0.01)
			skeleton.set_bone_pose_scale(bone_idx, localPoseScale)
	
	#localPosePos.y += 0.1
	#skeleton.set_bone_pose_position(bone_idx, localPosePos)
	#print(skeleton.get_bone_pose_position(bone_idx))
	
	#var pose: Transform3D = skeleton.global_transform * skeleton.get_bone_global_pose(bone_idx)
	#print(pose.origin)
