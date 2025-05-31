extends DollPart

@export var clothesMat:MyMasterBodyMat

@onready var plain_panties: MeshInstance3D = %PlainPanties
@onready var plain_panties_shifted: MeshInstance3D = %PlainPantiesShifted


func applyOption(_optionID:String, _value:Variant):
	if(clothesMat != null):
		if(_optionID == "color"):
			clothesMat.set_shader_parameter("albedo", _value)
	if(_optionID == "shifted"):
		plain_panties.visible = !_value
		plain_panties_shifted.visible = _value
		triggerDollPartFlagsUpdate()
			
func applyCharOption(_optionID:String, _value:Variant):
	updateThicknessBody(_optionID)

func gatherPartFlags(_theFlags:Dictionary):
	if(!getOptionValue("shifted", false)):
		_theFlags["HidePenis"] = true

func applyPartFlags(_theFlags:Dictionary):
	if(_theFlags.has("HidePanties") && _theFlags["HidePanties"]):
		visible = false
	else:
		visible = true
	if(_theFlags.has("CrotchBulge") && _theFlags["CrotchBulge"]):
		setBlendshape("CrotchBulge", 1.0)
	else:
		setBlendshape("CrotchBulge", 0.0)
