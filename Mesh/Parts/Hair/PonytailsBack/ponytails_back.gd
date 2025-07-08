extends DollPart

var hairMat:ShaderMaterial
var rubberBandMat:ShaderMaterial

@onready var ponytails_back: MeshInstance3D = %PonytailsBack
@onready var rubber_bands: MeshInstance3D = %RubberBands

func grabMaterials():
	hairMat = ponytails_back.get_surface_override_material(0)
	rubberBandMat = rubber_bands.get_surface_override_material(0)

func applyOption(_optionID:String, _value:Variant):
	applyHairMatOption(hairMat, _optionID, _value)
	if(_optionID == "bandColor"):
		rubberBandMat.set_shader_parameter("albedo", _value)
	#if(hairMat != null):
		#if(_optionID == "colorRoot"):
			#hairMat.set_shader_parameter("root_color", _value)
		#if(_optionID == "colorTip"):
			#hairMat.set_shader_parameter("tip_color", _value)
			#
			#var newCol:Color = _value
			#newCol.s = clamp(newCol.s*0.2, 0.4, 1.0)
			#newCol.v = max(min(0.7, newCol.v), 0.5)
			#hairMat.set_shader_parameter("primary_color", newCol)
			#
		#if(_optionID == "colorShinePrimary"):
			#hairMat.set_shader_parameter("primary_color", _value)
		#if(_optionID == "colorShineSecondary"):
			#hairMat.set_shader_parameter("secondary_color", _value)
