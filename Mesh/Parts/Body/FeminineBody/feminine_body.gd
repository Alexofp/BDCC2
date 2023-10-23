extends DollPart

@onready var body = $rig/Skeleton3D/Body
@onready var animTree = $SkeletonAnimTree
@onready var animPlayer = $MyAnimationPlayer

@export var bodyMat:StandardMaterial3D
@export var layeredBodyMat:ShaderMaterial

var extraTransformsPerBone = {}

func _ready():
	super._ready()
	#process_priority = 1
	#animTree.active = true

func applyOption(_optionID: String, _value):
	if(_optionID == "thickbutt"):
		#bodyMat.albedo_color = RNG.pick([Color.RED, Color.BLUE, Color.GREEN, Color.PINK, Color.PURPLE])
		setBlendshape(body, "ThickButt", _value)
		setBlendshape($rig/Skeleton3D/Digilegs, "ThickButt", _value)
		setBlendshape($rig/Skeleton3D/PlantiLegs, "ThickButt", _value)
		setBlendshape($rig/Skeleton3D/CrotchFemale, "ThickButt", _value)
		setBlendshape($rig/Skeleton3D/CrotchMale, "ThickButt", _value)
	if(_optionID == "breastsize"):
		animTree["parameters/BreastsSize/add_amount"] = _value
		#setBoneScale("DEF-breast.L", max(0.1, _value))
		#setBoneScale("DEF-breast.R", max(0.1, _value))
		#setBoneScale("DEF-foot.R", max(0.1, _value))
		#setBoneOffset("DEF-foot.R", Vector3(_value, 0.0, 0.0))
		#setBoneOffset("DEF-breast.L", Vector3(0.0, 0.0, _value))
		#setBoneOffset("DEF-breast.R", Vector3(0.0, 0.0, _value))
		#setBoneScaleAndOffset("DEF-breast.L", max(0.1, _value+1.0), Vector3(0.0, 0.0, -_value/20.0))
		#setBoneScaleAndOffset("DEF-breast.R", max(0.1, _value+1.0), Vector3(0.0, 0.0, -_value/20.0))
		setBonePosScalerom3Lerp("DEF-breast.R",\
			Vector3(-0.001, 0.023, -0.005), Vector3(0.4, 0.4, 0.4),\
			Vector3(), Vector3(1.0, 1.0, 1.0),\
			Vector3(0.009, -0.002, -0.035), Vector3(2.0, 2.0, 2.0),\
			_value)
		setBonePosScalerom3Lerp("DEF-breast.L",\
			Vector3(0.001, 0.023, -0.005), Vector3(0.4, 0.4, 0.4),\
			Vector3(), Vector3(1.0, 1.0, 1.0),\
			Vector3(-0.009, -0.002, -0.035), Vector3(2.0, 2.0, 2.0),\
			_value)
	if(_optionID == "headsize"):
		animTree["parameters/HeadSize/add_amount"] = _value * 0.1
		setBoneRestScale("DEF-head", max(0.1, _value*0.1+1.0))
	if(_optionID == "tailsize"):
		setBoneRestScale("DEF-tail_base", max(0.1, _value+1.0))
	if(_optionID == "height"):
		animTree["parameters/HeightTall/add_amount"] = _value
		setBoneOffset("DEF-spine.001", Vector3(0.0, 0.04*_value, 0.0)) #0.12
		setBoneOffset("DEF-spine.002", Vector3(0.0, 0.04*_value, 0.0)) #0.03
		setBoneOffset("DEF-spine.003", Vector3(0.0, 0.04*_value, 0.0))
		setBoneOffset("DEF-upper_arm.L.001", Vector3(0.0, 0.03*_value, 0.0))
		setBoneOffset("DEF-forearm.L", Vector3(0.0, 0.03*_value, 0.0))
		setBoneOffset("DEF-forearm.L.001", Vector3(0.0, 0.03*_value, 0.0))
		setBoneOffset("DEF-hand.L", Vector3(0.0, 0.03*_value, 0.0))
		
		setBoneOffset("DEF-upper_arm.R.001", Vector3(0.0, 0.03*_value, 0.0))
		setBoneOffset("DEF-forearm.R", Vector3(0.0, 0.03*_value, 0.0))
		setBoneOffset("DEF-forearm.R.001", Vector3(0.0, 0.03*_value, 0.0))
		setBoneOffset("DEF-hand.R", Vector3(0.0, 0.03*_value, 0.0))
	if(_optionID == "legstype"):
		if(_value == "digi"):
			$rig/Skeleton3D/Digilegs.visible = true
			$rig/Skeleton3D/PlantiLegs.visible = false
		if(_value == "planti"):
			$rig/Skeleton3D/Digilegs.visible = false
			$rig/Skeleton3D/PlantiLegs.visible = true

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
	
	if(true):
		#var theskeleton:Skeleton3D = getSkeleton()
		var boneId = theskeleton.find_bone("DEF-upper_arm.L.001")
		
		var currentTrans:Transform3D = getBetterGlobalPose(theskeleton, boneId)#theskeleton.get_bone_global_pose_no_override(boneId)#theskeleton.get_bone_global_pose(theskeleton.get_bone_parent(boneId))
		
		var newTransform:Transform3D = Transform3D.IDENTITY
		newTransform = newTransform.translated(Vector3(0.0, 0.5, 0.0))
		#newTransform = newTransform.rotated(Vector3(0.0, 1.0, 0.0), 90.0)
		
		#$rig/Skeleton3D/MeshInstance3D.transform = currentTrans * newTransform
		#theskeleton.set_bone_global_pose_override(boneId, currentTrans * newTransform, 1.0, true)
		#theskeleton.force_update_bone_child_transform(boneId)
		#theskeleton.set_bone_pose_scale(boneId, Vector3(2.0, 2.0, 2.0))
		#print("DEF-forearm.L.001"," ", currentTrans.origin)
		#theskeleton.set_bone_pose_position(boneId, Vector3(0.0, 0.3, 0.0))

func getBetterGlobalPose(theskeleton:Skeleton3D, boneID:int):
	#return theskeleton.get_bone_global_pose_no_override(boneID)
	return theskeleton.get_bone_global_pose(theskeleton.get_bone_parent(boneID)) * skeleton.get_bone_pose(boneID)

func playAnim(dollAnim:String, howFast:float = 1.0):
	if(dollAnim in [DollAnim.Walk, DollAnim.Run, DollAnim.Fall]):
		animPlayer.play("IdleAnimations/FemWalkCycle")
	else:
		animPlayer.play("IdleAnimations/SexyIdle")

func applyBaseSkinData(_data : BaseSkinData):
	if(bodyMat != null):
		bodyMat.albedo_color = _data.skinColor
	if(layeredBodyMat != null):
		layeredBodyMat.set_shader_parameter("albedo", _data.skinColor)
		
		if(_data.skinType == "fur"):
			layeredBodyMat.set_shader_parameter("texture_albedo", preload("res://Mesh/Textures/Body/BodyColor.png"))
			layeredBodyMat.set_shader_parameter("texture_normal", preload("res://Mesh/Textures/Body/BodyNormal.png"))
		else:
			layeredBodyMat.set_shader_parameter("texture_albedo", null)
			layeredBodyMat.set_shader_parameter("texture_normal", null)
