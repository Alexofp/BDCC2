extends Node3D
class_name DollPart

@export var bindToParentSkeleton = false
var meshes:Array[MeshInstance3D] = []
@export var attachmentPoints:Dictionary = {}
var skeleton: Skeleton3D
var dollRef:WeakRef
var partRef:WeakRef

var extraTransformsPerBone = {}

func shouldBindToParentSkeleton() -> bool:
	if(bindToParentSkeleton == null):
		bindToParentSkeleton = false
	return bindToParentSkeleton

func getDoll() -> Doll:
	if(dollRef == null):
		return null
	return dollRef.get_ref()

func getBodypart() -> BaseBodypart:
	if(partRef == null):
		return null
	return partRef.get_ref()

func getOptionValue(valueID: String, defaultValue = null):
	var thePart = getBodypart()
	if(thePart == null):
		return defaultValue
	return thePart.getOptionValue(valueID, defaultValue)

func getSkinOptionValue(valueID: String, defaultValue = null):
	var thePart = getBodypart()
	if(thePart == null):
		return defaultValue
	return thePart.getSkinOptionValue(valueID, defaultValue)


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

func playAnim(_dollAnim:String, _howFast:float = 1.0):
	pass

func applyBaseSkinData(_data : BaseSkinData):
	pass

func onPartSkinDataChanged(part, newSkinData):
	applyBaseSkinData(newSkinData)

func applySkinOption(_optionID: String, _value):
	pass

func onPartSkinOptionChanged(_optionID, _value):
	applySkinOption(_optionID, _value)





var boneRests = {}
func setBoneRestScale(boneName: String, boneScale: float):
	var theskeleton:Skeleton3D = getSkeleton()
	var boneId = theskeleton.find_bone(boneName)
	if(boneId < 0):
		return
	if(!boneRests.has(boneId)):
		boneRests[boneId] = theskeleton.get_bone_rest(boneId)
	if(true):
		var newTransform:Transform3D = Transform3D.IDENTITY#getBoneExtraTransform(boneId)#theskeleton.get_bone_global_pose_no_override(boneId)#Transform3D.IDENTITY
		newTransform = newTransform.scaled(Vector3(boneScale,boneScale,boneScale))
		
		theskeleton.set_bone_rest(boneId, boneRests[boneId] * newTransform)
		theskeleton.reset_bone_pose(boneId)

func setBoneScale(boneName: String, boneScale: float):
	var theskeleton:Skeleton3D = getSkeleton()
	var boneId = theskeleton.find_bone(boneName)
	if(boneId < 0):
		return
	#var newTransform:Transform3D = Transform3D.IDENTITY
	#newTransform = newTransform.scaled(Vector3(boneScale,boneScale,boneScale))
	
	#theskeleton.set_bone_pose_scale(boneId, Vector3(boneScale,boneScale,boneScale))
	#skeleton.set_bone_custom_pose(boneId, newTransform)
	
	if(true):
		var newTransform:Transform3D = Transform3D.IDENTITY#getBoneExtraTransform(boneId)#theskeleton.get_bone_global_pose_no_override(boneId)#Transform3D.IDENTITY
		newTransform = newTransform.scaled(Vector3(boneScale,boneScale,boneScale))
		
		extraTransformsPerBone[str(boneId)] = newTransform
		
	#if(true):
	#	var currentTrans:Transform3D = theskeleton.get_bone_global_pose_no_override(boneId)
	#	var newTransform:Transform3D = Transform3D.IDENTITY#theskeleton.get_bone_global_pose_no_override(boneId)
	#	newTransform = newTransform.scaled(Vector3(boneScale,boneScale,boneScale))
	#	theskeleton.set_bone_global_pose_override(boneId, currentTrans * newTransform, 1.0, true)

func setBoneRestOffset(boneName: String, offset: Vector3):
	var theskeleton:Skeleton3D = getSkeleton()
	var boneId = theskeleton.find_bone(boneName)
	if(boneId < 0):
		return
	if(!boneRests.has(boneId)):
		print("REMEMBERED: "+boneName)
		boneRests[boneId] = theskeleton.get_bone_rest(boneId)
	if(true):
		var newTransform:Transform3D = Transform3D.IDENTITY#getBoneExtraTransform(boneId)#theskeleton.get_bone_global_pose_no_override(boneId)#Transform3D.IDENTITY
		newTransform = newTransform.translated(offset)
		
		theskeleton.set_bone_rest(boneId, boneRests[boneId] * newTransform)
		theskeleton.reset_bone_pose(boneId)

func setBoneOffset(boneName: String, offset: Vector3):
	var theskeleton:Skeleton3D = getSkeleton()
	var boneId = theskeleton.find_bone(boneName)
	if(boneId < 0):
		return
	
	if(true):
		var newTransform:Transform3D = Transform3D.IDENTITY#getBoneExtraTransform(boneId)#theskeleton.get_bone_global_pose_no_override(boneId)#Transform3D.IDENTITY
		newTransform = newTransform.translated(offset)
		
		extraTransformsPerBone[str(boneId)] = newTransform
		
#	if(true):
#		var currentTrans:Transform3D = theskeleton.get_bone_global_pose_no_override(boneId)
#		var newTransform:Transform3D = Transform3D.IDENTITY#theskeleton.get_bone_global_pose_no_override(boneId)
#		newTransform = newTransform.translated(offset)
#		theskeleton.set_bone_global_pose_override(boneId, currentTrans * newTransform, 1.0, true)
#
	#theskeleton.set_bone_pose_position(boneId, offset)
	#theskeleton.get_bone_global_pose(_parent_bone_idx)

func setBoneScaleAndOffset(boneName: String, boneScale: float, offset: Vector3):
	var theskeleton:Skeleton3D = getSkeleton()
	var boneId = theskeleton.find_bone(boneName)
	if(boneId < 0):
		return
	#var newTransform:Transform3D = Transform3D.IDENTITY
	#newTransform = newTransform.scaled(Vector3(boneScale,boneScale,boneScale))
	
	#theskeleton.set_bone_pose_scale(boneId, Vector3(boneScale,boneScale,boneScale))
	#skeleton.set_bone_custom_pose(boneId, newTransform)
	
	if(true):
		var newTransform:Transform3D = Transform3D.IDENTITY#getBoneExtraTransform(boneId)#theskeleton.get_bone_global_pose_no_override(boneId)#Transform3D.IDENTITY
		newTransform = newTransform.scaled(Vector3(boneScale,boneScale,boneScale))
		newTransform = newTransform.translated(offset)
		
		extraTransformsPerBone[str(boneId)] = newTransform

func setBoneTransformFrom2Lerp(boneName: String, zeroTransform: Transform3D, oneTransform: Transform3D, value):
	var theskeleton:Skeleton3D = getSkeleton()
	var boneId = theskeleton.find_bone(boneName)
	if(boneId < 0):
		return
	if(true):
		extraTransformsPerBone[str(boneId)] = zeroTransform.interpolate_with(oneTransform, value)

func setBonePosScalerom2Lerp(boneName: String, zeroPos: Vector3, zeroScale: Vector3, onePos: Vector3, oneScale: Vector3, value):
	var theskeleton:Skeleton3D = getSkeleton()
	var boneId = theskeleton.find_bone(boneName)
	if(boneId < 0):
		return
		
	var newTransform:Transform3D = Transform3D.IDENTITY#theskeleton.get_bone_global_pose_no_override(boneId)
	newTransform = newTransform.scaled(zeroScale * max(0.0, 1.0 - value) + oneScale * value)
	newTransform = newTransform.translated(zeroPos * max(0.0, 1.0 - value) + onePos * value)
	
	if(true):
		extraTransformsPerBone[str(boneId)] = newTransform

func setBonePosScalerom3Lerp(boneName: String, minusOnePose: Vector3, minusOneScale: Vector3, zeroPos: Vector3, zeroScale: Vector3, onePos: Vector3, oneScale: Vector3, value):
	var theskeleton:Skeleton3D = getSkeleton()
	var boneId = theskeleton.find_bone(boneName)
	if(boneId < 0):
		return
		
	var newTransform:Transform3D = Transform3D.IDENTITY#theskeleton.get_bone_global_pose_no_override(boneId)
	if(value < 0):
		value = -value
		newTransform = newTransform.scaled(zeroScale * max(0.0, 1.0 - value) + minusOneScale * value)
		newTransform = newTransform.translated(zeroPos * max(0.0, 1.0 - value) + minusOnePose * value)
	else:
		newTransform = newTransform.scaled(zeroScale * max(0.0, 1.0 - value) + oneScale * value)
		newTransform = newTransform.translated(zeroPos * max(0.0, 1.0 - value) + onePos * value)
	
	if(true):
		extraTransformsPerBone[str(boneId)] = newTransform

func getBoneExtraTransform(boneId: int) -> Transform3D:
	if(extraTransformsPerBone.has(str(boneId))):
		return extraTransformsPerBone[str(boneId)]
	
	return Transform3D.IDENTITY

func _process(_delta):
	var theskeleton:Skeleton3D = getSkeleton()
	
	var dakeys = extraTransformsPerBone.keys()
	#dakeys.sort()
	for boneIdstr in dakeys:
		var boneId = int(boneIdstr)
		#var boneId = theskeleton.find_bone(boneName)
		#if(boneId < 0):
		#	return
		var currentTrans:Transform3D = getBetterGlobalPose(theskeleton, boneId)#theskeleton.get_bone_global_pose_no_override(boneId)
		theskeleton.set_bone_global_pose_override(boneId, currentTrans * extraTransformsPerBone[str(boneId)], 1.0, true)
	

func getBetterGlobalPose(theskeleton:Skeleton3D, boneID:int):
	#return theskeleton.get_bone_global_pose_no_override(boneID)
	return theskeleton.get_bone_global_pose(theskeleton.get_bone_parent(boneID)) * skeleton.get_bone_pose(boneID)
