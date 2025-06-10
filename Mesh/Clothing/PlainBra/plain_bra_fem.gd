extends DollPart

@onready var plain_bra: MeshInstance3D = %PlainBra
@onready var plain_bra_pulled_down: MeshInstance3D = %PlainBraPulledDown

var clothesMat:MyMasterBodyMat

func grabMaterials():
	clothesMat = plain_bra.get_surface_override_material(0)

func getSyncedBodypartSlots() -> Array:
	return [BodypartSlot.Body]

func applySyncedBodypartOption(_slot:int, _optionID:String, _value:Variant):
	updateBreasts(_optionID, _value)

func applyOption(_optionID:String, _value:Variant):
	if(clothesMat != null):
		if(_optionID == "color"):
			clothesMat.set_shader_parameter("albedo", _value)
	if(_optionID == "pulledDown"):
		plain_bra.visible = !_value
		plain_bra_pulled_down.visible = _value
		triggerDollPartFlagsUpdate()
			
func applyCharOption(_optionID:String, _value:Variant):
	updateThicknessBody(_optionID)

func gatherPartFlags(_theFlags:Dictionary):
	if(!getOptionValue("pulledDown", false)):
		_theFlags["HideNipples"] = true
		_theFlags["ForceBreastCleavage"] = true
#
func applyPartFlags(_theFlags:Dictionary):
	if(_theFlags.has("HideBra") && _theFlags["HideBra"]):
		visible = false
	else:
		visible = true
	updateBreastsCleavage(getBodypartOptionValue(BodypartSlot.Body, "BreastsCleavage", 0.0))
	#
	#if(_theFlags.has("CrotchBulge") && _theFlags["CrotchBulge"]):
		#setBlendshape("CrotchBulge", 1.0)
	#else:
		#setBlendshape("CrotchBulge", 0.0)
