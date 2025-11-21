@tool
extends SkeletonModifier3D
class_name MoveBoneModifier

@export_enum(" ") var boneName: String
@export var translation: Vector3 = Vector3(0, 0, 0)
#@export var localSpace: bool = false

func _validate_property(property: Dictionary) -> void:
	if property.name in ["boneName"]:
		var skeleton: Skeleton3D = get_skeleton()
		if skeleton:
			property.hint = PROPERTY_HINT_ENUM
			property.hint_string = skeleton.get_concatenated_bone_names()

func _process_modification_with_delta(_delta: float) -> void:
	var skeleton: Skeleton3D = get_skeleton()
	if !skeleton:
		return # Never happen, but for the safety.
	var bone_idx: int = skeleton.find_bone(boneName)
	
	if bone_idx < 0:
		return

	var pose := skeleton.get_bone_pose_position(bone_idx)
	#var offset := translation
	#if localSpace:
	#	offset = pose.basis * translation

	#pose.origin += offset

	#skeleton.set_bone_global_pose_override(
		#bone_idx,
		#pose,
		#1.0,
		#false  # persistent override = false (normal modifier behavior)
	#)
	skeleton.set_bone_pose_position(bone_idx, pose + translation)
