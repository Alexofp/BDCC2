extends DollPart

@export var eyeMat:ShaderMaterial
@export var eyeRightMat:ShaderMaterial
@export var headMat:StandardMaterial3D
@export var mouthMat:StandardMaterial3D
@export var tongueMat:StandardMaterial3D
@export var browsMat:StandardMaterial3D
@export var eyelashesMat:StandardMaterial3D
@export var noseMat:StandardMaterial3D
@onready var eyes = $CanineRig/Skeleton3D/Eyes
@onready var canine_head_fluff = $CanineRig/Skeleton3D/CanineHeadFluff


func updateMuzzleSizeAndLength():
	var muzzlesize = getOptionValue("muzzlesize", 0.0)
	var muzzlelen = getOptionValue("muzzlelen", 0.0)
	setBoneScaleAndOffset("muzzle", max(0.1, muzzlesize*0.1+1.0), Vector3(0.0, muzzlelen/50.0, 0.0))

func applyOption(_optionID: String, _value):
	if(_optionID == "muzzlesize"):
		updateMuzzleSizeAndLength()
	if(_optionID == "muzzlelen"):
		updateMuzzleSizeAndLength()
	if(_optionID == "nosebridge"):
		#setBoneOffset("NoseBridge", Vector3(0.0, _value/20.0, -_value/20.0))
		animation_tree["parameters/NodeBridge/add_amount"] = _value
	if(_optionID == "cheekfluff"):
		if(_value):
			canine_head_fluff.visible = true
		else:
			canine_head_fluff.visible = false
	if(_optionID == "eyessize"):
		animation_tree["parameters/EyesSize/add_amount"] = -_value
	if(_optionID == "eyesspacing"):
		animation_tree["parameters/EyesSpacing/add_amount"] = -_value

func applySkinOption(_optionID: String, _value):
	if(_optionID == "mouthcolor"):
		if(mouthMat != null):
			mouthMat.albedo_color = _value
	if(_optionID == "tonguecolor"):
		if(tongueMat != null):
			tongueMat.albedo_color = _value
	if(_optionID == "nosecolor"):
		if(noseMat != null):
			noseMat.albedo_color = _value
	
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
		#headMat.set_shader_parameter("albedo", _data.skinColor)
		headMat.albedo_color = _data.skinColor
		
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
	
	if(Input.is_action_just_pressed("debug_randomkey")):
		if(animation_tree["parameters/Mouth/current_state"] == "state_0"):
			animation_tree["parameters/Mouth/transition_request"] = "state_1"
		elif(animation_tree["parameters/Mouth/current_state"] == "state_1"):
			animation_tree["parameters/Mouth/transition_request"] = "state_2"
		elif(animation_tree["parameters/Mouth/current_state"] == "state_2"):
			animation_tree["parameters/Mouth/transition_request"] = "state_3"
		else:
			animation_tree["parameters/Mouth/transition_request"] = "state_0"
