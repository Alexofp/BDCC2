extends GenericPart
class_name DollPart

@export var attachmentPoints:Dictionary = {}

var extraTransformsPerBone = {}
var extraBoneOffset = {}
var extraBoneRotation = {}
var extraBoneScale = {}

var extraToExtraPart = {}

func getBodypart() -> BaseBodypart:
	return getPart()

func _ready():
	pass

var triedToFindSkeleton3d = false
var cachedSkeleton3d:Skeleton3D
func getSkeleton() -> Skeleton3D:
	if(cachedSkeleton3d == null && !triedToFindSkeleton3d):
		cachedSkeleton3d = Util.getFirstSkeleton3DOfANode(self)
		triedToFindSkeleton3d = true
	return cachedSkeleton3d

func hasSkeleton() -> bool:
	return getSkeleton() != null

func getBodypartSlotObject(bodypartSlot: String):
	if(bodypartSlot == ""):
		return self
	if(attachmentPoints.has(bodypartSlot)):
		return get_node(attachmentPoints[bodypartSlot])
	return self

func getBodypartSlotObjectOrNull(bodypartSlot: String):
	if(bodypartSlot == ""):
		return self
	if(attachmentPoints.has(bodypartSlot)):
		return get_node(attachmentPoints[bodypartSlot])
	return null

func applyParentOption(_optionID: String, _value):
	pass

func onParentPartOptionChanged(_optionID, _value):
	applyParentOption(_optionID, _value)

func applyBaseSkinData(_data : BaseSkinData):
	pass

func applyBaseSkinDataToStandardMaterial(_data: BaseSkinData, _mat:StandardMaterial3D):
	_data.applyToStandardMaterial(_mat)
	
func applyBaseSkinDataToShaderMaterial(_data: BaseSkinData, _mat:ShaderMaterial):
	_data.applyToShaderMaterial(_mat)

func onPartSkinDataChanged(_part, newSkinData):
	applyBaseSkinData(newSkinData)

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
	if(zeroScale == oneScale):
		newScale = zeroScale
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

func doFollowSkeleton(theskeleton:Skeleton3D, followSkeleton:Skeleton3D):
	if(theskeleton != null && followSkeleton != null):
		for _i in range(followSkeleton.get_bone_count()):
			var boneID = _i
			
			theskeleton.set_bone_pose_position(boneID, followSkeleton.get_bone_pose_position(boneID) + (extraBoneOffset[boneID] if extraBoneOffset.has(boneID) else Vector3.ZERO))
			theskeleton.set_bone_pose_rotation(boneID, followSkeleton.get_bone_pose_rotation(boneID) * (extraBoneRotation[boneID] if extraBoneRotation.has(boneID) else Quaternion.IDENTITY))
			theskeleton.set_bone_pose_scale(boneID, followSkeleton.get_bone_pose_scale(boneID) * (extraBoneScale[boneID] if extraBoneScale.has(boneID) else Vector3.ONE))

func _process(_delta):
	pass

func updateAlphas(_alphaTextures:Array):
	pass

func followMainSkeleton(theskeleton:Skeleton3D):
	var followSkeleton:Skeleton3D = getMainDollSkeleton()
	
	if(theskeleton != null && followSkeleton != null):
		for _i in range(followSkeleton.get_bone_count()):
			var boneID = _i
			
			theskeleton.set_bone_pose_position(boneID, followSkeleton.get_bone_pose_position(boneID) + (extraBoneOffset[boneID] if extraBoneOffset.has(boneID) else Vector3.ZERO))
			theskeleton.set_bone_pose_rotation(boneID, followSkeleton.get_bone_pose_rotation(boneID) * (extraBoneRotation[boneID] if extraBoneRotation.has(boneID) else Quaternion.IDENTITY))
			theskeleton.set_bone_pose_scale(boneID, followSkeleton.get_bone_pose_scale(boneID) * (extraBoneScale[boneID] if extraBoneScale.has(boneID) else Vector3.ONE))

func applyPoseToSkeletonDeffered():
	var theskeleton:Skeleton3D = getSkeleton()
	if(theskeleton == null):
		return
	var dakeys = extraTransformsPerBone.keys()
	for boneIdstr in dakeys:
		var boneID = boneIdstr
		var currentTrans:Transform3D = theskeleton.get_bone_global_pose(theskeleton.get_bone_parent(boneID)) * theskeleton.get_bone_pose(boneID)#getBetterGlobalPose(theskeleton, boneId)#theskeleton.get_bone_global_pose_no_override(boneId)
		theskeleton.call_deferred("set_bone_global_pose_override", boneID, currentTrans * extraTransformsPerBone[boneID], 1.0, true)

func getMainDollSkeleton() -> Skeleton3D:
	return getDoll().getMainSkeleton()
