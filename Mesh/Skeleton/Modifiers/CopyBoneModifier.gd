@tool
extends SkeletonModifier3D
class_name CopyBoneModifier

@export var target_skeleton_path: NodePath:
	set(value):
		target_skeleton_path = value
		_update_target_skeleton()
		_update_bone_indices()
		notify_property_list_changed()

@export var target_bone_name: String = "":
	set(value):
		target_bone_name = value
		_update_bone_indices()

@export var source_bone_name: String = "":
	set(value):
		source_bone_name = value
		_update_bone_indices()

var _target_skeleton: Skeleton3D
var _target_bone_idx: int = -1
var _source_bone_idx: int = -1

func _ready() -> void:
	if(!Engine.is_editor_hint()):
		_update_target_skeleton()
		_update_bone_indices()

func setTargetSkeleton(_skeleton:Skeleton3D):
	if(!_skeleton):
		target_skeleton_path = NodePath()
		return
	target_skeleton_path = get_path_to(_skeleton)

func _process_modification() -> void:
	if not _target_skeleton or _target_bone_idx == -1 or _source_bone_idx == -1:
		return

	var src_skeleton := get_skeleton()
	if(!src_skeleton):
		return

	var target_world: Transform3D = _target_skeleton.global_transform * _target_skeleton.get_bone_global_pose(_target_bone_idx)
	var desired_local: Transform3D = src_skeleton.global_transform.affine_inverse() * target_world
	src_skeleton.set_bone_global_pose(_source_bone_idx, desired_local)

func _update_target_skeleton() -> void:
	if target_skeleton_path:
		_target_skeleton = get_node(target_skeleton_path) as Skeleton3D
	else:
		_target_skeleton = null

func _update_bone_indices() -> void:
	if _target_skeleton and target_bone_name != "":
		_target_bone_idx = _target_skeleton.find_bone(target_bone_name)
	else:
		_target_bone_idx = -1

	var src_skeleton := get_skeleton()
	if src_skeleton and source_bone_name != "":
		_source_bone_idx = src_skeleton.find_bone(source_bone_name)
	else:
		_source_bone_idx = -1

func _get_property_list() -> Array[Dictionary]:
	var properties: Array[Dictionary] = []

	var src_skeleton := get_skeleton()
	var source_bone_names: String = ""
	if src_skeleton:
		source_bone_names = src_skeleton.get_concatenated_bone_names()

	var target_bone_names: String = ""
	if _target_skeleton:
		target_bone_names = _target_skeleton.get_concatenated_bone_names()

	properties.append({
		"name": "source_bone_name",
		"type": TYPE_STRING,
		"hint": PROPERTY_HINT_ENUM,
		"hint_string": source_bone_names,
	})

	properties.append({
		"name": "target_bone_name",
		"type": TYPE_STRING,
		"hint": PROPERTY_HINT_ENUM,
		"hint_string": target_bone_names,
	})

	return properties
