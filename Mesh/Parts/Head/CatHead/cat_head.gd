extends DollPart

@export var eyeMat:ShaderMaterial
@export var eyeRightMat:ShaderMaterial
@export var headMat:ShaderMaterial
@export var mouthMat:StandardMaterial3D
@export var tongueMat:StandardMaterial3D
@onready var eyes = $Armature_002/Skeleton3D/EYES

func applyOption(_optionID: String, _value):
	if(_optionID == "muzzlesize"):
		setBoneScale("MuzzleRoot", max(0.1, _value*0.2+1.0))
	if(_optionID == "nosebridge"):
		setBoneOffset("NoseBridge", Vector3(0.0, _value/20.0, -_value/20.0))

func applySkinOption(_optionID: String, _value):
	if(_optionID == "mouthcolor"):
		if(mouthMat != null):
			mouthMat.albedo_color = _value
	if(_optionID == "tonguecolor"):
		if(tongueMat != null):
			tongueMat.albedo_color = _value
	
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
			if(_value == "robot"):
				eyeMat.set_shader_parameter("texture_albedo", preload("res://Mesh/Textures/Eyes/roboteye.png"))
			else:
				eyeMat.set_shader_parameter("texture_albedo", preload("res://Mesh/Textures/Eyes/eye.png"))

	if(_optionID == "eyehue_right"):
		if(eyeRightMat != null):
			eyeRightMat.set_shader_parameter("Shift_Hue", _value)
	if(_optionID == "eyesaturation_right"):
		if(eyeRightMat != null):
			eyeRightMat.set_shader_parameter("Shift_Saturation", _value)
	if(_optionID == "eyetype_right"):
		if(eyeRightMat != null):
			if(_value == "robot"):
				eyeRightMat.set_shader_parameter("texture_albedo", preload("res://Mesh/Textures/Eyes/roboteye.png"))
			else:
				eyeRightMat.set_shader_parameter("texture_albedo", preload("res://Mesh/Textures/Eyes/eye.png"))

func applyBaseSkinData(_data : BaseSkinData):
	if(headMat != null):
		headMat.set_shader_parameter("albedo", _data.skinColor)
		
		if(_data.skinType == "fur"):
			headMat.set_shader_parameter("texture_albedo", preload("res://Mesh/Parts/Head/CatHead/textures/headcolor.png"))
			headMat.set_shader_parameter("texture_normal", preload("res://Mesh/Parts/Head/CatHead/textures/headnormal.png"))
		else:
			headMat.set_shader_parameter("texture_albedo", null)
			headMat.set_shader_parameter("texture_normal", null)
