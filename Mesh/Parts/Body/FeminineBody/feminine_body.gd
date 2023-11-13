extends DollPart

@onready var body = $rig/Skeleton3D/Body
@onready var animTree = $SkeletonAnimTree
@onready var animPlayer = $MyAnimationPlayer

@export var bodyMat:StandardMaterial3D
@export var layeredBodyMat:ShaderMaterial

func _ready():
	super._ready()
	#process_priority = 1
	#animTree.active = true

func findSkeleton() -> Skeleton3D:
	return $rig/Skeleton3D

func getSubSkeleton() -> Skeleton3D:
	return $FeminineSkeleton.getSkeleton()

func applySkinOption(_optionID: String, _value):
	if(_optionID == "skinlayers"):
		if(layeredBodyMat != null):
			var theColors = []
			#theColors.resize(_value.size())
			var theTextures = []
			for layerInfo in _value:
				theColors.append(layerInfo["color"])
				theTextures.append(GlobalRegistry.getTextureVariant(TextureType.PartSkin, TextureSubType.Generic, layerInfo["id"]).getTexture())
			layeredBodyMat.set_shader_parameter("layerAmount", _value.size())
			layeredBodyMat.set_shader_parameter("layers", theTextures)
			layeredBodyMat.set_shader_parameter("layerColors", PackedColorArray(theColors))
		
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
		setBoneScale("DEF-head", max(0.1, _value*0.1+1.0))
	if(_optionID == "tailsize"):
		setBoneScale("DEF-tail_base", max(0.1, _value+1.0))
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

func playAnim(dollAnim:String, _howFast:float = 1.0):
	if(dollAnim in [DollAnim.Walk, DollAnim.Run, DollAnim.Fall]):
		$FeminineSkeleton.getAnimPlayer().play("FemWalkCycle")
		#animPlayer.play("IdleAnimations/FemWalkCycle")
	else:
		$FeminineSkeleton.getAnimPlayer().play("SexyIdle")
		#animPlayer.play("IdleAnimations/SexyIdle")
	pass

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

