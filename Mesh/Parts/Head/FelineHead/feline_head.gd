extends DollPart

@export var eyeMat:ShaderMaterial
@export var eyeRightMat:ShaderMaterial
@export var headMat:StandardMaterial3D
@export var mouthMat:ShaderMaterial
@export var browsMat:StandardMaterial3D
@export var eyelashesMat:StandardMaterial3D
@onready var eyes = $FelineRig/Skeleton3D/Eyes
@onready var cheek_fluff = $FelineRig/Skeleton3D/CheekFluff
@onready var pattern_texture = $PatternTexture

func _ready():
	super._ready()
	if(headMat != null):
		headMat.albedo_texture = pattern_texture.getTexture()
		#headMat.set_shader_parameter("texture_layers", pattern_texture.getTexture())
		#headMat.set_shader_parameter("alpha_mask", alphaTexture.getTexture())

func updateMuzzleSizeAndLength():
	var muzzlesize = getOptionValue("muzzlesize", 0.0)
	var muzzlelen = getOptionValue("muzzlelen", 0.0)
	setBoneScaleAndOffset("DEF-muzzle", max(0.1, muzzlesize*0.1+1.0), Vector3(0.0, muzzlelen/50.0, 0.0))
	animation_tree["parameters/NeckBulge/add_amount"] = clamp(-muzzlelen, 0.0, 0.8)
	
func applyOption(_optionID: String, _value):
	if(_optionID == "muzzlewidth"):
		animation_tree["parameters/MuzzleWidth/add_amount"] = _value
	if(_optionID == "nosebig"):
		animation_tree["parameters/NoseBig/add_amount"] = _value
	if(_optionID == "muzzlesize"):
		updateMuzzleSizeAndLength()
	if(_optionID == "muzzlelen"):
		updateMuzzleSizeAndLength()
	if(_optionID == "nosebridge"):
		#setBoneOffset("NoseBridge", Vector3(0.0, _value/20.0, -_value/20.0))
		animation_tree["parameters/NodeBridge/add_amount"] = _value
	if(_optionID == "fluffdown"):
		if(cheek_fluff != null):
			setBlendshape(cheek_fluff, "FluffDown", _value)
	if(_optionID == "fluffshort"):
		if(cheek_fluff != null):
			setBlendshape(cheek_fluff, "FluffShort", _value)
	if(_optionID == "fluffwide"):
		if(cheek_fluff != null):
			setBlendshape(cheek_fluff, "FluffWide", _value)
	if(_optionID == "cheekfluff"):
		if(cheek_fluff != null):
			if(_value):
				cheek_fluff.visible = true
			else:
				cheek_fluff.visible = false
	if(_optionID == "eyessize"):
		animation_tree["parameters/EyesSize/add_amount"] = -_value
	if(_optionID == "eyesspacing"):
		animation_tree["parameters/EyesSpacing/add_amount"] = -_value
	applySkinOption(_optionID, _value)

func updatePatternTexture():
	pattern_texture.clear()
	var baseInfo:BaseSkinData = getBodypart().getBaseSkinData()
	if(baseInfo != null):
		pattern_texture.addSimpleLayer(preload("res://Mesh/Parts/Head/FelineHead/Textures/MyFelineHead LowPoly_FelineHead_BaseColor.png"), baseInfo.skinColor)
	
	var _value = getOptionValue("skinlayers", [])
	pattern_texture.addLayers(_value)

func applySkinOption(_optionID: String, _value):
	if(_optionID == "skinlayers"):
		if(headMat != null):
			if(true):
				updatePatternTexture()
				return
			pattern_texture.clear()
			for layerInfo in _value:
				var theTexture = load(layerInfo["id"])
				#var theTexture = GlobalRegistry.getTextureVariant(TextureType.PartSkin, TextureSubType.Generic, layerInfo["id"]).getTexture()
				
				if(layerInfo.has("isPattern") && layerInfo["isPattern"]):
					pattern_texture.addPatternLayer(theTexture, layerInfo["color"], layerInfo["color2"], layerInfo["color3"])
				else:
					pattern_texture.addSimpleLayer(theTexture, layerInfo["color"])
	if(_optionID == "mouthcolor"):
		if(mouthMat != null):
			mouthMat.set_shader_parameter("r_pattern", _value)
	if(_optionID == "tonguecolor"):
		if(mouthMat != null):
			mouthMat.set_shader_parameter("g_pattern", _value)
	if(_optionID == "teethcolor"):
		if(mouthMat != null):
			mouthMat.set_shader_parameter("b_pattern", _value)
	if(_optionID == "mouthrough"):
		if(mouthMat != null):
			mouthMat.set_shader_parameter("roughness", _value)
	if(_optionID == "mouthspec"):
		if(mouthMat != null):
			mouthMat.set_shader_parameter("specular", _value)
	
	if(_optionID == "brows"):
		if(browsMat != null):
			var textureVariant:TextureVariant = GlobalRegistry.getTextureVariant(TextureType.Brows, TextureSubType.Generic, _value)
			if(textureVariant != null):
				browsMat.albedo_texture = textureVariant.getTexture()
	if(_optionID == "eyelashes"):
		if(eyelashesMat != null):
			var textureVariant:TextureVariant = GlobalRegistry.getTextureVariant(TextureType.Eyelashes, TextureSubType.Generic, _value)
			if(textureVariant != null):
				eyelashesMat.albedo_texture = textureVariant.getTexture()

	
	if(_optionID == "sameeyes"):
		if(_value):
			eyes.set_surface_override_material(1, eyeMat)
		else:
			eyes.set_surface_override_material(1, eyeRightMat)
		
	if(_optionID == "eyehue"):
		if(eyeMat != null):
			eyeMat.set_shader_parameter("Shift_Hue", _value)
	if(_optionID == "eyesaturation"):
		if(eyeMat != null):
			eyeMat.set_shader_parameter("Shift_Saturation", _value)
	if(_optionID == "eyetype"):
		if(eyeMat != null):
			var textureVariant:TextureVariant = GlobalRegistry.getTextureVariant(TextureType.Eyes, TextureSubType.Generic, _value)
			if(textureVariant != null):
				eyeMat.set_shader_parameter("texture_albedo", textureVariant.getTexture())

	if(_optionID == "eyehue_right"):
		if(eyeRightMat != null):
			eyeRightMat.set_shader_parameter("Shift_Hue", _value)
	if(_optionID == "eyesaturation_right"):
		if(eyeRightMat != null):
			eyeRightMat.set_shader_parameter("Shift_Saturation", _value)
	if(_optionID == "eyetype_right"):
		if(eyeRightMat != null):
			var textureVariant:TextureVariant = GlobalRegistry.getTextureVariant(TextureType.Eyes, TextureSubType.Generic, _value)
			if(textureVariant != null):
				eyeRightMat.set_shader_parameter("texture_albedo", textureVariant.getTexture())

func applyBaseSkinData(_data : BaseSkinData):
	if(headMat != null):
		applyBaseSkinDataToStandardMaterial(_data, headMat)
		headMat.albedo_color = Color.WHITE
		if(true):
			updatePatternTexture()
			return
		
		#headMat.set_shader_parameter("albedo", _data.skinColor)
		#headMat.albedo_color = _data.skinColor
		
		#if(_data.skinType == "fur"):
		#	headMat.set_shader_parameter("texture_albedo", preload("res://Mesh/Parts/Head/CatHead/textures/headcolor.png"))
		#	headMat.set_shader_parameter("texture_normal", preload("res://Mesh/Parts/Head/CatHead/textures/headnormal.png"))
		#else:
		#	headMat.set_shader_parameter("texture_albedo", null)
		#	headMat.set_shader_parameter("texture_normal", null)
@onready var animation_tree = $AnimationTree
@onready var look_direction_timer = $LookDirectionTimer
var eyesTween:Tween
var eyesDownTween:Tween
var eyesDirection:Vector2
func _on_look_direction_timer_timeout():
	look_direction_timer.wait_time = RNG.randf_range(1.0, 3.0)
	if(RNG.chance(10)):
		look_direction_timer.wait_time = 0.3
	if(eyesDownTween):
		eyesDownTween.kill()
	eyesDownTween = create_tween()
	eyesDownTween.tween_property(animation_tree, "parameters/ClosedEyes/blend_amount", RNG.randf_range(0.0, 0.2), 0.5).set_trans(Tween.TRANS_CUBIC)
	#animation_tree["parameters/ClosedEyes/blend_amount"] = RNG.randf_range(0.0, 0.2)
	#var eyesDirection = animation_tree["parameters/EyesDirection/blend_position"]
	if(eyesTween):
		eyesTween.kill()
	eyesTween = create_tween()
	eyesTween.tween_property(animation_tree, "parameters/EyesDirection/blend_position", Vector2(RNG.randf_rangeX2(-0.3, 0.3), RNG.randf_rangeX2(-0.3, 0.3)), 0.05).set_trans(Tween.TRANS_BOUNCE)
	if(RNG.chance(50)):
		eyesTween.tween_property(animation_tree, "parameters/EyesDirection/blend_position", Vector2(RNG.randf_rangeX2(-0.5, 0.5), RNG.randf_rangeX2(-0.5, 0.5)), 0.5).set_trans(Tween.TRANS_BOUNCE)
	#animation_tree["parameters/EyesDirection/blend_position"] = Vector2(RNG.randf_rangeX2(-0.3, 0.3), RNG.randf_rangeX2(-0.3, 0.3))

func _process(_delta):
	super._process(_delta)
	
	applyPoseToSkeletonDeffered()
	
	if(Input.is_action_just_pressed("debug_randomkey") && animation_tree != null):
		if(animation_tree["parameters/Mouth/current_state"] == "state_0"):
			animation_tree["parameters/Mouth/transition_request"] = "state_1"
		elif(animation_tree["parameters/Mouth/current_state"] == "state_1"):
			animation_tree["parameters/Mouth/transition_request"] = "state_2"
		elif(animation_tree["parameters/Mouth/current_state"] == "state_2"):
			animation_tree["parameters/Mouth/transition_request"] = "state_3"
		elif(animation_tree["parameters/Mouth/current_state"] == "state_3"):
			animation_tree["parameters/Mouth/transition_request"] = "state_4"
		else:
			animation_tree["parameters/Mouth/transition_request"] = "state_0"
