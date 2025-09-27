extends DollExtraPart

@onready var ball_piercing: MeshInstance3D = %BallPiercing
var piercingMat:ShaderMaterial

func grabMaterials():
	piercingMat = ball_piercing.get_surface_override_material(0)

func applyOption(_optionID:String, _value:Variant):
	if(piercingMat):
		if(_optionID == "piercings"):
			var c1:Color = _value[1] if _value.size() > 1 else Color.WHITE
			var c2:Color = _value[2] if _value.size() > 2 else Color.WHITE
			
			piercingMat.set_shader_parameter("albedo", c1)
			piercingMat.set_shader_parameter("color_mask_r", c2)
