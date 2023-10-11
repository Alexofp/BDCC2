extends Node3D
class_name DollPart

@export var bindToParentSkeleton = false
var meshes:Array[MeshInstance3D] = []
@export var attachmentPoints:Dictionary = {}
var skeleton: Skeleton3D
var dollRef:WeakRef

func shouldBindToParentSkeleton() -> bool:
	return bindToParentSkeleton

func getDoll() -> Doll:
	if(dollRef == null):
		return null
	return dollRef.get_ref()

func deleteSkeleton():
	for node in skeleton.get_children():
		skeleton.remove_child(node)
		add_child(node)
	skeleton.queue_free()
	skeleton = null

func _ready():
	skeleton = Util.getFirstSkeleton3DOfANode(self)
	if(bindToParentSkeleton):
		deleteSkeleton()
	meshes = Util.getAllMeshInstancesOfANode(self)

func setSkeleton(newSkeleton:Skeleton3D):
	for mesh in meshes:
		mesh.skeleton = mesh.get_path_to(newSkeleton)

func getSkeleton() -> Skeleton3D:
	return skeleton

func hasSkeleton() -> bool:
	return skeleton != null

func getBodypartSlotObject(bodypartSlot: String):
	if(attachmentPoints.has(bodypartSlot)):
		return get_node(attachmentPoints[bodypartSlot])
	return self

func setBlendshape(mesh: MeshInstance3D, blendShapeID: String, val: float):
	if(mesh == null):
		return
	var blendShapeIndex = mesh.find_blend_shape_by_name(blendShapeID)
	if(blendShapeIndex >= 0):
		mesh.set_blend_shape_value(blendShapeIndex, val)

func applyOption(_optionID: String, _value):
	pass

func onPartOptionChanged(_optionID, _value):
	applyOption(_optionID, _value)

func applyParentOption(_optionID: String, _value):
	pass

func onParentPartOptionChanged(_optionID, _value):
	applyParentOption(_optionID, _value)
