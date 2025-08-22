extends DollExtraPart

@onready var spikes: MeshInstance3D = %Spikes

var piercingMat:MyMasterMaterial

func grabMaterials():
	piercingMat = spikes.get_surface_override_material(0)

func updatePiercingScale():
	var theBreastsValue:float = getOptionValue("breasts", 1.0)
	var theNippleShape:float = getOptionValue("nippleShape", 0.0)
	
	var baseScale:float = 1.0
	if(theBreastsValue > 1.0):
		baseScale = remap(theBreastsValue, 1.0, 2.0, 1.0, 1.3)
	else:
		baseScale = remap(theBreastsValue, 1.0, 0.0, 1.0, 0.7)
	
	var baseScale2:float = remap(theNippleShape, 0.0, 1.0, 1.0, 1.2)
	
	spikes.scale = baseScale * baseScale2 * Vector3(0.053, 0.053, 0.053)
	

func applyOption(_optionID:String, _value:Variant):
	if(_optionID == "breasts"):
		updatePiercingScale()
	elif(_optionID == "breastsCleavage"):
		#setBlendshape("BreastsCleavage", _value if !getCachedPartFlag("ForceBreastCleavage", false) else 1.0)
		pass
	elif(_optionID == "nippleShape"):
		updatePiercingScale()
	
	if(piercingMat):
		if(_optionID == "nipplePiercing"):
			var c1:Color = _value[1] if _value.size() > 1 else Color.WHITE
			var c2:Color = _value[2] if _value.size() > 2 else Color.WHITE
			
			piercingMat.set_shader_parameter("albedo", c1)
			piercingMat.set_shader_parameter("color_mask_r", c2)

func applyPartFlags(_theFlags:Dictionary):
	if(_theFlags.has("HideNipples") && _theFlags["HideNipples"]):
		spikes.visible = false
	else:
		spikes.visible = true
		
