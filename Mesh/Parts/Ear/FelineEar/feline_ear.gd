extends DollPart

@export var ear:MeshInstance3D = null
@export var earFluff:MeshInstance3D = null
var earMat:MyMasterBodyMat
var piercingsMat:MyMasterBodyMat
@export var piercingsTwoRings:MeshInstance3D = null
@export var tassels:MeshInstance3D = null
var tasselsMat:MyMasterBodyMat
var fluffMat:StandardMaterial3D

func grabMaterials():
	earMat = ear.get_surface_override_material(0)
	piercingsMat = piercingsTwoRings.get_surface_override_material(0)
	tasselsMat = tassels.get_surface_override_material(0)
	fluffMat = earFluff.get_surface_override_material(0)

func applyOption(_optionID:String, _value:Variant):
	if(_optionID == "piercings"):
		if(piercingsTwoRings):
			piercingsTwoRings.visible = (_value == "TwoRings")
	if(_optionID == "tassels"):
		if(tassels):
			tassels.visible = (_value)
	if(_optionID == "piercingsColor"):
		if(piercingsMat):
			piercingsMat.set_shader_parameter("albedo", _value)
	if(_optionID == "tasselsColor"):
		if(tasselsMat):
			tasselsMat.set_shader_parameter("albedo", _value)
	if(_optionID == "pattern"):
		applyColormaskPatternToMyMat(earMat, _value)
	if(_optionID == "fluffColor"):
		if(fluffMat):
			fluffMat.albedo_color = _value

func applySkinTypeData(_skinTypeData:SkinTypeData):
	if(earMat == null):
		return
	
	earMat.set_shader_parameter("albedo", _skinTypeData.color)
	
