extends DollPart

@export var ear:MeshInstance3D = null
@export var earFluff:MeshInstance3D = null
#@export var tassels:MeshInstance3D = null

var earMat:ShaderMaterial
#var tasselsMat:ShaderMaterial
var fluffMat:ShaderMaterial

func grabMaterials():
	earMat = ear.get_surface_override_material(0)
	#tasselsMat = tassels.get_surface_override_material(0)
	fluffMat = earFluff.get_surface_override_material(0)
	pass
	
func applyOption(_optionID:String, _value:Variant):
	#if(_optionID == "tassels"):
		#if(tassels):
			#tassels.visible = (_value)
	#if(_optionID == "tasselsColor"):
		#if(tasselsMat):
			#tasselsMat.set_shader_parameter("albedo", _value)
	if(_optionID == "pattern"):
		applyColormaskPatternToMyMat(earMat, _value)
	if(_optionID == "fluffColor"):
		if(fluffMat):
			fluffMat.set_shader_parameter("albedo", _value)

func applySkinTypeData(_skinType:int, _skinTypeData:SkinTypeData):
	if(earMat == null):
		return
	
	earMat.set_shader_parameter("albedo", _skinTypeData.color)
	
