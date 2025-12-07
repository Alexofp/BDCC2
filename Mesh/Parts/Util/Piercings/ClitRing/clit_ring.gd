extends DollExtraPart

@onready var clit_ring: MeshInstance3D = %ClitRing

var piercingMat:ShaderMaterial

func grabMaterials():
	piercingMat = clit_ring.get_surface_override_material(0)

#func updatePiercingScale():
	#var theBreastsValue:float = getOptionValue("breasts", 1.0)
	#var theNippleShape:float = getOptionValue("nippleShape", 0.0)
	#
	#var baseScale:float = 1.0
	#if(theBreastsValue > 1.0):
		#baseScale = remap(theBreastsValue, 1.0, 2.0, 1.0, 1.3)
	#else:
		#baseScale = remap(theBreastsValue, 1.0, 0.0, 1.0, 0.7)
	#
	#var baseScale2:float = remap(theNippleShape, 0.0, 1.0, 1.0, 1.2)
	#
	#dumbbell.scale = baseScale * baseScale2 * Vector3(0.053, 0.053, 0.053)
	#

func applyOption(_optionID:String, _value:Variant):
	if(piercingMat):
		if(_optionID == "clitPiercing"):
			var c1:Color = _value[1] if _value.size() > 1 else Color.WHITE
			var c2:Color = _value[2] if _value.size() > 2 else Color.WHITE
			#var c3:Color = _value[3] if _value.size() > 3 else Color.WHITE
			
			piercingMat.set_shader_parameter("albedo", c1)
			piercingMat.set_shader_parameter("color_mask_r", c2)
			#piercingMat.set_shader_parameter("color_mask_g", c3)
#
func applyPartFlags(_theFlags:Dictionary):
	var theHide:bool = (_theFlags.has("HideVagina") && _theFlags["HideVagina"])
	var theNormal:bool = (_theFlags.has("NormalVagina") && _theFlags["NormalVagina"])
	if(theHide || theNormal):
		clit_ring.visible = false
	else:
		clit_ring.visible = true
		
