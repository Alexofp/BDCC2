extends DollPart

@onready var body = $rig/Skeleton3D/Body

@export var layeredBodyMat:ShaderMaterial
@export var bodyMat:StandardMaterial3D
@export var nipplesMat:ShaderMaterial
@export var genitalsMat:ShaderMaterial
@export var pubesMat:StandardMaterial3D

@onready var pattern_texture = $PatternTexture
@onready var alphaTexture = $AlphaTexture
@onready var final_texture = $FinalTexture

# LAYERS ARE BORKED
func updatePatternTexture():
	pattern_texture.clear()
	var baseInfo:BaseSkinData = getBodypart().getBaseSkinData()
	if(baseInfo != null):
		if(baseInfo.skinType == "fur"):
			pattern_texture.addSimpleLayer(preload("res://Mesh/Parts/Body/FeminineBodyNew/Textures/Fur/MyBody Substance Painter new_Body_BaseColor.png"), baseInfo.skinColor)
		elif(baseInfo.skinType == "skin"):
			pattern_texture.addSimpleLayer(preload("res://Mesh/Parts/Body/FeminineBodyNew/Textures/Skin/MyBody Substance Painter new_Body_BaseColor.png"), baseInfo.skinColor)
		else:
			pattern_texture.addSimpleLayer(preload("res://Mesh/Parts/Body/FeminineBodyNew/Textures/Fur/furwhite.png"), baseInfo.skinColor)
	
	var _value = getOptionValue("skinlayers", [])
	pattern_texture.addLayers(_value) # FIX ME
	
	final_texture.clear()
	final_texture.addTextureWithAlphaLayer(pattern_texture.getTexture(), alphaTexture.getTexture())
	final_texture.queueUpdateDelayed()
	
func updateNormalMap():
	var _value = getOptionValue("muscletan", 0.0)
	if(_value <= 0.0):
		if(bodyMat != null):
			bodyMat.normal_texture = theNormalNormalMap
			bodyMat.normal_scale = 1.0
	else:
		if(bodyMat != null):
			bodyMat.normal_texture = preload("res://Mesh/Parts/Body/FeminineBodyNew/Textures/Skin/Normal Map from Mesh Body.png")
			bodyMat.normal_scale = _value
				
func _ready():
	super._ready()
	#process_priority = 1
	#animTree.active = true
	if(bodyMat != null):
		bodyMat.albedo_texture = final_texture.getTexture()
	if(layeredBodyMat != null):
		layeredBodyMat.set_shader_parameter("texture_layers", pattern_texture.getTexture())
		layeredBodyMat.set_shader_parameter("alpha_mask", alphaTexture.getTexture())
	#await get_tree().process_frame
	#await get_tree().process_frame
	#updatePatternTexture()
	#alphaTexture.addSimpleAlphaLayer(preload("res://Mesh/Parts/Body/FeminineBody/Textures/BodyAlphaTest.png"))
	#alphaTexture.addSimpleAlphaLayer(preload("res://Mesh/Parts/Body/FeminineBody/Textures/BodyAlphaTest2.png"))
	
func getSkeleton() -> Skeleton3D:
	return $rig/Skeleton3D
	
func findSkeleton() -> Skeleton3D:
	return $rig/Skeleton3D

func getSubSkeleton() -> Skeleton3D:
	return $BodySkeleton.getSkeleton()

func _process(_delta):
	super._process(_delta)
	
	followMainSkeleton($rig/Skeleton3D)
	#doFollowSkeleton($rig/Skeleton3D, $FeminineBodySkeleton/rig/Skeleton3D)
	

func applySkinOption(_optionID: String, _value):
	if(_optionID == "skinlayers"):
		updatePatternTexture()
		if(layeredBodyMat != null && false):
			pattern_texture.clear()
			var theColors = []
			#theColors.resize(_value.size())
			var theTextures = []
			for layerInfo in _value:
				var theTexture = GlobalRegistry.getTextureVariant(TextureType.PartSkin, TextureSubType.Generic, layerInfo["id"]).getTexture()
				
				theColors.append(layerInfo["color"])
				theTextures.append(theTexture)
				pattern_texture.addSimpleLayer(theTexture, layerInfo["color"])
			#layeredBodyMat.set_shader_parameter("layerAmount", _value.size())
			#layeredBodyMat.set_shader_parameter("layers", theTextures)
			#layeredBodyMat.set_shader_parameter("layerColors", PackedColorArray(theColors))
		
	if(_optionID == "nipplehue"):
		if(nipplesMat != null):
			nipplesMat.set_shader_parameter("hueShift", _value)
	if(_optionID == "nipplesat"):
		if(nipplesMat != null):
			nipplesMat.set_shader_parameter("saturationMult", _value)
	if(_optionID == "nipplevalue"):
		if(nipplesMat != null):
			nipplesMat.set_shader_parameter("valueMult", _value)
	if(_optionID == "genhue"):
		if(genitalsMat != null):
			genitalsMat.set_shader_parameter("hueShift", _value)
	if(_optionID == "gensat"):
		if(genitalsMat != null):
			genitalsMat.set_shader_parameter("saturationMult", _value)
	if(_optionID == "genvalue"):
		if(genitalsMat != null):
			genitalsMat.set_shader_parameter("valueMult", _value)
	if(_optionID == "pubes"):
		if(pubesMat != null):
			var textureVariant:TextureVariant = GlobalRegistry.getTextureVariant(TextureType.PubicHair, TextureSubType.Generic, _value)
			if(textureVariant != null):
				pubesMat.albedo_texture = textureVariant.getTexture()
	if(_optionID == "nippletexture"):
		if(nipplesMat != null):
			var textureVariant:TextureVariant = GlobalRegistry.getTextureVariant(TextureType.Nipples, TextureSubType.Generic, _value)
			if(nipplesMat != null):
				nipplesMat.set_shader_parameter("texture_albedo", textureVariant.getTexture())
				#nipplesMat.albedo_texture = textureVariant.getTexture()
	if(_optionID == "muscletan"):
		updateNormalMap()
				
func applyOption(_optionID: String, _value):
	if(_optionID == "shoulderswidth"):
		#(0.034039, 0.149208, -0.024705)
		#(0.016787, 0.118755, -0.024731)
		var diff = Vector3(0.034039, 0.149208, -0.024705) - Vector3(0.016787, 0.118755, -0.024731)
		setBonePosScalerom2Lerp("DEF-upper_arm.L", Vector3(0.0, 0.0, 0.0), Vector3(1.0, 1.0, 1.0), diff, Vector3(1.0, 1.0, 1.0), _value)
		var diff2 = diff
		diff2.x *= -1.0
		setBonePosScalerom2Lerp("DEF-upper_arm.R", Vector3(0.0, 0.0, 0.0), Vector3(1.0, 1.0, 1.0), diff2, Vector3(1.0, 1.0, 1.0), _value)
	if(_optionID == "thickbutt"):
		#bodyMat.albedo_color = RNG.pick([Color.RED, Color.BLUE, Color.GREEN, Color.PINK, Color.PURPLE])
		setBlendshape(body, "Thickness", _value)
		setBlendshape($rig/Skeleton3D/DigiLegs, "Thickness", _value)
		setBlendshape($rig/Skeleton3D/PlantiLegs, "Thickness", _value)
		setBlendshape($rig/Skeleton3D/FemaleCrotch, "Thickness", _value)
		setBlendshape($rig/Skeleton3D/MaleCrotch, "Thickness", _value)
		setBlendshape($rig/Skeleton3D/PubicHair, "Thickness", _value)
	if(_optionID == "muscles"):
		setBlendshape(body, "Muscles", _value)
		setBlendshape($rig/Skeleton3D/DigiLegs, "Muscles", _value)
		setBlendshape($rig/Skeleton3D/PlantiLegs, "Muscles", _value)
		setBlendshape($rig/Skeleton3D/FemaleCrotch, "Muscles", _value)
		setBlendshape($rig/Skeleton3D/MaleCrotch, "Muscles", _value)
		setBlendshape($rig/Skeleton3D/PubicHair, "Muscles", _value)
	if(_optionID == "crotchwidth"):
		setBlendshape(body, "PussyWide", _value)
		#setBlendshape($rig/Skeleton3D/DigiLegs, "Muscles", _value)
		#setBlendshape($rig/Skeleton3D/PlantiLegs, "Muscles", _value)
		setBlendshape($rig/Skeleton3D/FemaleCrotch, "PussyWide", _value)
		setBlendshape($rig/Skeleton3D/MaleCrotch, "PussyWide", _value)
		setBlendshape($rig/Skeleton3D/PubicHair, "PussyWide", _value)
	if(_optionID == "breastsize"):
		#setBoneScale("DEF-breast.L", max(0.1, _value))
		#setBoneScale("DEF-breast.R", max(0.1, _value))
		#setBoneScale("DEF-foot.R", max(0.1, _value))
		#setBoneOffset("DEF-foot.R", Vector3(_value, 0.0, 0.0))
		#setBoneOffset("DEF-breast.L", Vector3(0.0, 0.0, _value))
		#setBoneOffset("DEF-breast.R", Vector3(0.0, 0.0, _value))
		#setBoneScaleAndOffset("DEF-breast.L", max(0.1, _value+1.0), Vector3(0.0, 0.0, -_value/20.0))
		#setBoneScaleAndOffset("DEF-breast.R", max(0.1, _value+1.0), Vector3(0.0, 0.0, -_value/20.0))
		setBonePosScalerom3Lerp("DEF-breast.R",\
			Vector3(-0.011, 0.003, 0.025), Vector3(0.4, 0.4, 0.4),\
			Vector3(), Vector3(1.0, 1.0, 1.0),\
			Vector3(-0.009, -0.012, -0.015), Vector3(2.0, 2.0, 2.0),\
			_value)
		setBonePosScalerom3Lerp("DEF-breast.L",\
			Vector3(0.011, 0.003, 0.025), Vector3(0.4, 0.4, 0.4),\
			Vector3(), Vector3(1.0, 1.0, 1.0),\
			Vector3(0.009, -0.012, -0.015), Vector3(2.0, 2.0, 2.0),\
			_value)
		setBonePosScalerom3Lerp("DEF-nipple.R",\
			Vector3(), Vector3(2.0, 2.0, 2.0),\
			Vector3(), Vector3(1.0, 1.0, 1.0),\
			Vector3(), Vector3(0.6, 0.6, 0.6),\
			_value)
		setBonePosScalerom3Lerp("DEF-nipple.L",\
			Vector3(), Vector3(2.0, 2.0, 2.0),\
			Vector3(), Vector3(1.0, 1.0, 1.0),\
			Vector3(), Vector3(0.6, 0.6, 0.6),\
			_value)
	if(_optionID == "headsize"):
		setBoneScale("DEF-head", max(0.1, _value*0.1+1.0))
	if(_optionID == "tailsize"):
		setBoneScale("DEF-tail_base", max(0.1, _value+1.0))
	if(_optionID == "height"):
		setBoneOffset("DEF-spine.001", Vector3(0.0, 0.06*_value, 0.0)) #0.12
		setBoneOffset("DEF-spine.002", Vector3(0.0, 0.06*_value, 0.0)) #0.03
		setBoneOffset("DEF-spine.003", Vector3(0.0, 0.00*_value, 0.0))
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
			$rig/Skeleton3D/DigiLegs.visible = true
			$rig/Skeleton3D/PlantiLegs.visible = false
		if(_value == "planti"):
			$rig/Skeleton3D/DigiLegs.visible = false
			$rig/Skeleton3D/PlantiLegs.visible = true
	if(_optionID == "pussy"):
		updateCrotchVisibility()
	applySkinOption(_optionID, _value)

func playAnim(dollAnim:String, _howFast:float = 1.0):
	if(dollAnim in [DollAnim.Run]):
		$BodySkeleton.run()
	elif(dollAnim in [DollAnim.Walk, DollAnim.Fall]):
		#$FeminineSkeleton.getAnimPlayer().play("FemWalkCycle")
		#$BodySkeleton.getAnimPlayer().play("WalkSimple", -1.0, 1.7)
		$BodySkeleton.walk()
		#animPlayer.play("IdleAnimations/FemWalkCycle")
	else:
		#$FeminineSkeleton.getAnimPlayer().play("SexyIdle")
		#$FeminineSkeleton.getAnimPlayer().play("APose")
		#$BodySkeleton.getAnimPlayer().play("IdleSimple")
		$BodySkeleton.stand()
		#animPlayer.play("IdleAnimations/SexyIdle")
	pass

var theNormalNormalMap = null
func applyBaseSkinData(_data : BaseSkinData):
	#if(bodyMat != null):
	#	bodyMat.albedo_color = _data.skinColor
	if(bodyMat != null):
		applyBaseSkinDataToStandardMaterial(_data, bodyMat)
		bodyMat.albedo_color = Color.WHITE
		updatePatternTexture()
		
		if(_data.skinType == "fur"):
			theNormalNormalMap = preload("res://Mesh/Parts/Body/FeminineBodyNew/Textures/Fur/MyBody Substance Painter new_Body_Normal.png")
			updateNormalMap()
			bodyMat.roughness_texture = preload("res://Mesh/Parts/Body/FeminineBodyNew/Textures/Fur/MyBody Substance Painter new_Body_Roughness.png")
		elif(_data.skinType == "skin"):
			theNormalNormalMap = preload("res://Mesh/Parts/Body/FeminineBodyNew/Textures/Skin/MyBody Substance Painter new_Body_Normal.png")
			updateNormalMap()
			bodyMat.roughness_texture = preload("res://Mesh/Parts/Body/FeminineBodyNew/Textures/Skin/MyBody Substance Painter new_Body_Roughness.png")
		else:
			theNormalNormalMap = null
			updateNormalMap()
			bodyMat.roughness_texture = null
			
	if(layeredBodyMat != null):
		if(true):
			return
		applyBaseSkinDataToShaderMaterial(_data, layeredBodyMat)
		#layeredBodyMat.set_shader_parameter("albedo", _data.skinColor)
		
		if(_data.skinType == "fur"):
			#layeredBodyMat.set_shader_parameter("texture_albedo", preload("res://Mesh/Parts/Body/FeminineBodyNew/Textures/Fur/MyBody Substance Painter_Body_BaseColor.png"))
			layeredBodyMat.set_shader_parameter("texture_albedo", preload("res://Mesh/Parts/Body/FeminineBodyNew/Textures/Fur/furwhite.png"))
			theNormalNormalMap = preload("res://Mesh/Parts/Body/FeminineBodyNew/Textures/Fur/MyBody Substance Painter_Body_Normal.png")
			layeredBodyMat.set_shader_parameter("texture_normal", theNormalNormalMap)
			#layeredBodyMat.set_shader_parameter("texture_normal", preload("res://Mesh/Parts/Body/FeminineBody/Textures/Fur/BodyNormal.png"))
			layeredBodyMat.set_shader_parameter("texture_roughness", preload("res://Mesh/Parts/Body/FeminineBodyNew/Textures/Fur/MyBody Substance Painter_Body_Roughness.png"))
		#elif(_data.skinType == "skin"):
		elif(_data.skinType == "skin"):
			layeredBodyMat.set_shader_parameter("texture_albedo", preload("res://Mesh/Parts/Body/FeminineBodyNew/Textures/Skin/MyBody Substance Painter_Body_BaseColor.png"))
			theNormalNormalMap = preload("res://Mesh/Parts/Body/FeminineBodyNew/Textures/Skin/MyBody Substance Painter_Body_Normal.png")
			layeredBodyMat.set_shader_parameter("texture_normal", theNormalNormalMap)
			#layeredBodyMat.set_shader_parameter("texture_normal", preload("res://Mesh/Parts/Body/FeminineBodyNew/Textures/Skin/MyBody Substance Painter_Body_Normal.png"))
			layeredBodyMat.set_shader_parameter("texture_roughness", preload("res://Mesh/Parts/Body/FeminineBodyNew/Textures/Skin/MyBody Substance Painter_Body_Roughness.png"))
		else:
			layeredBodyMat.set_shader_parameter("texture_albedo", null)
			layeredBodyMat.set_shader_parameter("texture_normal", null)
			layeredBodyMat.set_shader_parameter("texture_roughness", null)

func onFirstPersonChange(newFirstPerson:bool) -> void:
	if(newFirstPerson):
		setBoneScale("DEF-neck.001", 0.001)
	else:
		setBoneScale("DEF-neck.001", 1.0)

func updateAlphas(_alphaTextures:Array):
	alphaTexture.clear()
	for theAlphaTexture in _alphaTextures:
		alphaTexture.addSimpleAlphaLayer(theAlphaTexture)

	final_texture.queueUpdateDelayed()

func updateCrotchVisibility():
	if(getDoll().hasPartTag(PartTag.Body_HideCrotch)):
		$rig/Skeleton3D/FemaleCrotch.visible = false
		$rig/Skeleton3D/MaleCrotch.visible = false
	else:
		var pussyType = getOptionValue("pussy", "nopussy")
		if(pussyType == "pussy"):
			$rig/Skeleton3D/MaleCrotch.visible = false
			$rig/Skeleton3D/FemaleCrotch.visible = true
		if(pussyType == "nopussy"):
			$rig/Skeleton3D/MaleCrotch.visible = true
			$rig/Skeleton3D/FemaleCrotch.visible = false

func applyPartTags(_hiddenParts:Dictionary):
	if(_hiddenParts.has(PartTag.Body_HideNipples)):
		$rig/Skeleton3D/Nipples.visible = false
	else:
		$rig/Skeleton3D/Nipples.visible = true

	if(_hiddenParts.has(PartTag.Head_HumanNeck)):
		$rig/Skeleton3D/NeckConnector.visible = true
		$rig/Skeleton3D/NeckConnectorFurry.visible = false
	else:
		$rig/Skeleton3D/NeckConnector.visible = false
		$rig/Skeleton3D/NeckConnectorFurry.visible = true
	
	if(_hiddenParts.has(PartTag.Body_MinimalBreastJiggle)):
		$rig/Skeleton3D/WiggleBone.properties = preload("res://Mesh/Parts/Body/FeminineBodyNew/BoobWiggleSettingsMinimal.tres")
		$rig/Skeleton3D/WiggleBone2.properties = preload("res://Mesh/Parts/Body/FeminineBodyNew/BoobWiggleSettingsMinimal.tres")
	else:
		$rig/Skeleton3D/WiggleBone.properties = preload("res://Mesh/Parts/Body/FeminineBodyNew/BoobWiggleSettingsRotation.tres")
		$rig/Skeleton3D/WiggleBone2.properties = preload("res://Mesh/Parts/Body/FeminineBodyNew/BoobWiggleSettingsRotation.tres")
	
	updateCrotchVisibility()
