extends DollExtraPart

@onready var skeleton_3d: Node3D = %Skeleton3D
#var beardMat:ShaderMaterial
var beardMat:StandardMaterial3D

func grabMaterials():
	beardMat = skeleton_3d.get_child(0).get_surface_override_material(0)

func applyOption(_optionID:String, _value:Variant):
	if(beardMat):
		if(_optionID == "beard"):
			var c1:Color = _value[1] if _value.size() > 1 else Color.BLACK
			#var c2:Color = _value[2] if _value.size() > 2 else Color.WHITE
			
			beardMat.albedo_color = c1
			#beardMat.set_shader_parameter("albedo", c1)

	if(_optionID == "lipsBig"):
		setBlendshape("LipsBig", _value)
	elif(_optionID == "jawWide"):
		setBlendshape("JawWide", _value)
	elif(_optionID == "mouthCurve"):
		setBlendshape("MouthCurve", _value)
	elif(_optionID == "noseWidth"):
		setBlendshape("NoseWidth", _value)
