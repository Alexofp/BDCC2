extends DollPart

@onready var body = $rig/Skeleton3D/Body
@onready var animTree = $SkeletonAnimTree

var extraTransformsPerBone = {}

func _ready():
	super._ready()
	#animTree.active = true

func applyOption(_optionID: String, _value):
	if(_optionID == "thickbutt"):
		setBlendshape(body, "ThickButt", _value)
	if(_optionID == "breastsize"):
		animTree["parameters/BreastsSize/add_amount"] = _value
		#setBoneScale("DEF-breast.L", max(0.1, _value))
		#setBoneScale("DEF-breast.R", max(0.1, _value))
		#setBoneScale("DEF-foot.R", max(0.1, _value))
		#setBoneOffset("DEF-foot.R", Vector3(_value, 0.0, 0.0))
		#setBoneOffset("DEF-breast.L", Vector3(0.0, 0.0, _value))
		#setBoneOffset("DEF-breast.R", Vector3(0.0, 0.0, _value))
		setBoneScaleAndOffset("DEF-breast.L", max(0.1, _value+1.0), Vector3(0.0, 0.0, -_value/20.0))
		setBoneScaleAndOffset("DEF-breast.R", max(0.1, _value+1.0), Vector3(0.0, 0.0, -_value/20.0))
	if(_optionID == "headsize"):
		animTree["parameters/HeadSize/add_amount"] = _value * 0.1
	if(_optionID == "height"):
		animTree["parameters/HeightTall/add_amount"] = _value

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
		
		extraTransformsPerBone[boneId] = newTransform
		
	if(true):
		var currentTrans:Transform3D = theskeleton.get_bone_global_pose_no_override(boneId)
		var newTransform:Transform3D = Transform3D.IDENTITY#theskeleton.get_bone_global_pose_no_override(boneId)
		newTransform = newTransform.scaled(Vector3(boneScale,boneScale,boneScale))
		theskeleton.set_bone_global_pose_override(boneId, currentTrans * newTransform, 1.0, true)

func setBoneOffset(boneName: String, offset: Vector3):
	var theskeleton:Skeleton3D = getSkeleton()
	var boneId = theskeleton.find_bone(boneName)
	if(boneId < 0):
		return
	
	if(true):
		var newTransform:Transform3D = Transform3D.IDENTITY#getBoneExtraTransform(boneId)#theskeleton.get_bone_global_pose_no_override(boneId)#Transform3D.IDENTITY
		newTransform = newTransform.translated(offset)
		
		extraTransformsPerBone[boneId] = newTransform
		
	if(true):
		var currentTrans:Transform3D = theskeleton.get_bone_global_pose_no_override(boneId)
		var newTransform:Transform3D = Transform3D.IDENTITY#theskeleton.get_bone_global_pose_no_override(boneId)
		newTransform = newTransform.translated(offset)
		theskeleton.set_bone_global_pose_override(boneId, currentTrans * newTransform, 1.0, true)
	
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
		
		extraTransformsPerBone[boneId] = newTransform
		
	if(true):
		var currentTrans:Transform3D = theskeleton.get_bone_global_pose_no_override(boneId)
		var newTransform:Transform3D = Transform3D.IDENTITY#theskeleton.get_bone_global_pose_no_override(boneId)
		newTransform = newTransform.scaled(Vector3(boneScale,boneScale,boneScale))
		newTransform = newTransform.translated(offset)
		theskeleton.set_bone_global_pose_override(boneId, currentTrans * newTransform, 1.0, true)

func getBoneExtraTransform(boneId: int) -> Transform3D:
	if(extraTransformsPerBone.has(boneId)):
		return extraTransformsPerBone[boneId]
	
	return Transform3D.IDENTITY
