extends DollPart

@export var eyeMat:ShaderMaterial
@export var eyeRightMat:ShaderMaterial
@export var headMat:ShaderMaterial
@export var mouthMat:StandardMaterial3D
@export var tongueMat:StandardMaterial3D
@export var browsMat:StandardMaterial3D
@export var eyelashesMat:StandardMaterial3D
@export var noseMat:StandardMaterial3D
@onready var eyes = $Armature_002/Skeleton3D/EYES

func updateMuzzleSizeAndLength():
	var muzzlesize = getOptionValue("muzzlesize", 0.0)
	var muzzlelen = getOptionValue("muzzlelen", 0.0)
	setBoneScaleAndOffset("MuzzleRoot", max(0.1, muzzlesize*0.2+1.0), Vector3(0.0, muzzlelen/40.0, 0.0))

func applyOption(_optionID: String, _value):
	if(_optionID == "muzzlesize"):
		updateMuzzleSizeAndLength()
	if(_optionID == "muzzlelen"):
		updateMuzzleSizeAndLength()
	if(_optionID == "nosebridge"):
		setBoneOffset("NoseBridge", Vector3(0.0, _value/20.0, -_value/20.0))
	applySkinOption(_optionID, _value)

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
		headMat.set_shader_parameter("albedo", _data.skinColor)
		
		if(_data.skinType == "fur"):
			headMat.set_shader_parameter("texture_albedo", preload("res://Mesh/Parts/Head/CatHead/textures/headcolor.png"))
			headMat.set_shader_parameter("texture_normal", preload("res://Mesh/Parts/Head/CatHead/textures/headnormal.png"))
		else:
			headMat.set_shader_parameter("texture_albedo", null)
			headMat.set_shader_parameter("texture_normal", null)

func _process(_delta):
	super._process(_delta)
	
	applyPoseToSkeletonDeffered()
