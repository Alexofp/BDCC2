extends DollPart

@onready var shorts: MeshInstance3D = %Shorts
@onready var shorts_pulled_down: MeshInstance3D = %Shorts_PulledDown

var clothesMat:MyMasterBodyMat

func grabMaterials():
	clothesMat = shorts.get_surface_override_material(0)

func applyOption(_optionID:String, _value:Variant):
	if(clothesMat != null):
		if(_optionID == "color1"):
			clothesMat.set_shader_parameter("color_mask_r", _value)
		if(_optionID == "color2"):
			clothesMat.set_shader_parameter("color_mask_g", _value)
		if(_optionID == "color3"):
			clothesMat.set_shader_parameter("color_mask_b", _value)
	if(_optionID == "pulledDown"):
		shorts.visible = !_value
		shorts_pulled_down.visible = _value
		triggerDollPartFlagsUpdate()
		triggerAlphaMaskUpdate()
			
func applyCharOption(_optionID:String, _value:Variant):
	updateThicknessBody(_optionID)

func gatherPartFlags(_theFlags:Dictionary):
	if(!getOptionValue("pulledDown", false)):
		_theFlags["HidePenis"] = true
		_theFlags["HidePanties"] = true

func applyPartFlags(_theFlags:Dictionary):
	if(_theFlags.has("CrotchBulge") && _theFlags["CrotchBulge"]):
		setBlendshape("CrotchBulge", 1.0)
	else:
		setBlendshape("CrotchBulge", 0.0)

func getBodyAlphaMask() -> Texture2D:
	if(getOptionValue("pulledDown", false)):
		return null
	return preload("res://Mesh/Clothing/Shorts/Textures/Alpha_Shorts.png")
