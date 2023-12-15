extends DollPart

@export var eyeMat:ShaderMaterial
@export var eyeRightMat:ShaderMaterial
@export var headMat:ShaderMaterial
@export var mouthMat:StandardMaterial3D
@export var tongueMat:StandardMaterial3D
@export var browsMat:StandardMaterial3D
@export var eyelashesMat:StandardMaterial3D
@export var noseMat:StandardMaterial3D
@onready var eyes = $"RIG-MaleArmature/Skeleton3D/Eyes_001"

func applyOption(_optionID: String, _value):
	pass
	
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
	if(_optionID == "age"):
		if(headMat != null):
			headMat.set_shader_parameter("normal_scale", _value)
	
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
		
		if(_data.skinType == "skin"):
			headMat.set_shader_parameter("texture_albedo", preload("res://Mesh/Parts/Head/MaleHumanHead/textures/MyMaleHead substance painter_MaleHead_BaseColor.png"))
			headMat.set_shader_parameter("texture_normal", preload("res://Mesh/Parts/Head/MaleHumanHead/textures/MyMaleHead substance painter_MaleHead_Normal.png"))
		else:
			headMat.set_shader_parameter("texture_albedo", null)
			headMat.set_shader_parameter("texture_normal", null)
