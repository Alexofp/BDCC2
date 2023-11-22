extends Node3D
class_name DollPart

@export var bindToParentSkeleton = false
var meshes:Array[MeshInstance3D] = []
@export var attachmentPoints:Dictionary = {}
var skeleton: Skeleton3D
var dollRef:WeakRef
var partRef:WeakRef

var extraTransformsPerBone = {}
var extraBoneOffset = {}
var extraBoneRotation = {}
var extraBoneScale = {}

var firstPerson:bool = false

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

func findSkeleton() -> Skeleton3D:
	return Util.getFirstSkeleton3DOfANode(self)

func _ready():
	skeleton = findSkeleton()
	if(bindToParentSkeleton):
		deleteSkeleton()
	meshes = Util.getAllMeshInstancesOfANode(self)

func setSkeletonForAllMeshes(newSkeleton:Skeleton3D):
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

func onPartSkinDataChanged(_part, newSkinData):
	applyBaseSkinData(newSkinData)

func applySkinOption(_optionID: String, _value):
	pass

func onPartSkinOptionChanged(_optionID, _value):
	applySkinOption(_optionID, _value)

func setBoneScale(boneName: String, boneScale: float):
	var theskeleton:Skeleton3D = getSkeleton()
	var boneId = theskeleton.find_bone(boneName)
	if(boneId < 0):
		return

	var newTransform:Transform3D = Transform3D.IDENTITY
	newTransform = newTransform.scaled(Vector3(boneScale,boneScale,boneScale))
	
	extraTransformsPerBone[boneId] = newTransform
	extraBoneScale[boneId] = Vector3(boneScale,boneScale,boneScale)
		
func setBoneOffset(boneName: String, offset: Vector3):
	var theskeleton:Skeleton3D = getSkeleton()
	var boneId = theskeleton.find_bone(boneName)
	if(boneId < 0):
		return
	
	var newTransform:Transform3D = Transform3D.IDENTITY
	newTransform = newTransform.translated(offset)
	
	extraTransformsPerBone[boneId] = newTransform
	extraBoneOffset[boneId] = offset

func setBoneScaleAndOffset(boneName: String, boneScale: float, offset: Vector3):
	var theskeleton:Skeleton3D = getSkeleton()
	var boneId = theskeleton.find_bone(boneName)
	if(boneId < 0):
		return
	
	var newTransform:Transform3D = Transform3D.IDENTITY#getBoneExtraTransform(boneId)#theskeleton.get_bone_global_pose_no_override(boneId)#Transform3D.IDENTITY
	newTransform = newTransform.scaled(Vector3(boneScale,boneScale,boneScale))
	newTransform = newTransform.translated(offset)
	
	extraTransformsPerBone[boneId] = newTransform
	extraBoneScale[boneId] = Vector3(boneScale,boneScale,boneScale)
	extraBoneOffset[boneId] = offset

func setBonePosScalerom2Lerp(boneName: String, zeroPos: Vector3, zeroScale: Vector3, onePos: Vector3, oneScale: Vector3, value):
	var theskeleton:Skeleton3D = getSkeleton()
	var boneId = theskeleton.find_bone(boneName)
	if(boneId < 0):
		return
		
	var newTransform:Transform3D = Transform3D.IDENTITY#theskeleton.get_bone_global_pose_no_override(boneId)
	var newScale = zeroScale * max(0.0, 1.0 - value) + oneScale * value
	var newPose = zeroPos * max(0.0, 1.0 - value) + onePos * value
	newTransform = newTransform.scaled(newScale)
	newTransform = newTransform.translated(newPose)
	
	extraTransformsPerBone[boneId] = newTransform
	extraBoneOffset[boneId] = newPose
	extraBoneScale[boneId] = newScale

func setBonePosScalerom3Lerp(boneName: String, minusOnePose: Vector3, minusOneScale: Vector3, zeroPos: Vector3, zeroScale: Vector3, onePos: Vector3, oneScale: Vector3, value):
	var theskeleton:Skeleton3D = getSkeleton()
	var boneId = theskeleton.find_bone(boneName)
	if(boneId < 0):
		return
		
	var newTransform:Transform3D = Transform3D.IDENTITY#theskeleton.get_bone_global_pose_no_override(boneId)
	if(value < 0):
		value = -value
		var newScale = zeroScale * max(0.0, 1.0 - value) + minusOneScale * value
		var newPos = zeroPos * max(0.0, 1.0 - value) + minusOnePose * value
		newTransform = newTransform.scaled(newScale)
		newTransform = newTransform.translated(newPos)
		extraBoneOffset[boneId] = newPos
		extraBoneScale[boneId] = newScale
	else:
		var newScale = zeroScale * max(0.0, 1.0 - value) + oneScale * value
		var newPos = zeroPos * max(0.0, 1.0 - value) + onePos * value
		newTransform = newTransform.scaled(newScale)
		newTransform = newTransform.translated(newPos)
		extraBoneOffset[boneId] = newPos
		extraBoneScale[boneId] = newScale
	
	extraTransformsPerBone[boneId] = newTransform

func getBoneExtraTransform(boneId: int) -> Transform3D:
	if(extraTransformsPerBone.has(boneId)):
		return extraTransformsPerBone[boneId]
	
	return Transform3D.IDENTITY

func getSubSkeleton() -> Skeleton3D:
	return null

func getFollowSkeleton() -> Skeleton3D:
	return getSubSkeleton()

func _process(_delta):
	var theskeleton:Skeleton3D = getSkeleton()
	var followSkeleton:Skeleton3D = getFollowSkeleton()
	
	if(theskeleton != null && followSkeleton != null):
		for _i in range(followSkeleton.get_bone_count()):
			var boneID = _i
			
			theskeleton.set_bone_pose_position(boneID, followSkeleton.get_bone_pose_position(boneID) + (extraBoneOffset[boneID] if extraBoneOffset.has(boneID) else Vector3.ZERO))
			theskeleton.set_bone_pose_rotation(boneID, followSkeleton.get_bone_pose_rotation(boneID) * (extraBoneRotation[boneID] if extraBoneRotation.has(boneID) else Quaternion.IDENTITY))
			theskeleton.set_bone_pose_scale(boneID, followSkeleton.get_bone_pose_scale(boneID) * (extraBoneScale[boneID] if extraBoneScale.has(boneID) else Vector3.ONE))
	elif(theskeleton != null):
		var dakeys = extraTransformsPerBone.keys()
		#dakeys.sort()
		for boneIdstr in dakeys:
			var boneId = boneIdstr
			#var boneId = theskeleton.find_bone(boneName)
			#if(boneId < 0):
			#	return
			var currentTrans:Transform3D = getBetterGlobalPose(theskeleton, boneId)#theskeleton.get_bone_global_pose_no_override(boneId)
			theskeleton.call_deferred("set_bone_global_pose_override", boneId, currentTrans * extraTransformsPerBone[boneId], 1.0, true)
			
			#theskeleton.set_bone_global_pose_override(boneId, currentTrans * extraTransformsPerBone[boneId], 1.0, true)
			
func getBetterGlobalPose(theskeleton:Skeleton3D, boneID:int) -> Transform3D:
	#return theskeleton.get_bone_global_pose_no_override(boneID)
	return theskeleton.get_bone_global_pose(theskeleton.get_bone_parent(boneID)) * skeleton.get_bone_pose(boneID)

func setFirstPerson(newFirstPerson:bool) -> void:
	if(firstPerson != newFirstPerson):
		firstPerson = newFirstPerson
		onFirstPersonChange(firstPerson)
		
func onFirstPersonChange(_newFirstPerson:bool) -> void:
	pass
