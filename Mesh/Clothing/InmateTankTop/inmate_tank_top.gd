extends DollPart

@onready var tank_top: MeshInstance3D = %TankTop
@onready var tank_top_pulled_up: MeshInstance3D = %TankTopPulledUp

var clothesMat:ShaderMaterial

func grabMaterials():
	clothesMat = tank_top.get_surface_override_material(0)
	pass

func getSyncedBodypartSlots() -> Array:
	return [BodypartSlot.Body]

func applySyncedBodypartOption(_slot:int, _optionID:String, _value:Variant):
	updateBreasts(_optionID, _value)

func applyOption(_optionID:String, _value:Variant):
	if(clothesMat != null):
		if(_optionID == "color1"):
			clothesMat.set_shader_parameter("color_mask_r", _value)
		if(_optionID == "color2"):
			clothesMat.set_shader_parameter("color_mask_g", _value)
		if(_optionID == "color3"):
			clothesMat.set_shader_parameter("color_mask_b", _value)
	if(_optionID == "pulledUp"):
		tank_top.visible = !_value
		tank_top_pulled_up.visible = _value
		triggerDollPartFlagsUpdate()
		triggerAlphaMaskUpdate()
			
func applyCharOption(_optionID:String, _value:Variant):
	updateThicknessBody(_optionID)

func gatherPartFlags(_theFlags:Dictionary):
	if(!getOptionValue("pulledUp", false)):
		_theFlags["HideNipples"] = true
		_theFlags["HideBra"] = true
		_theFlags["ForceZeroBreastCleavage"] = true
#
func applyPartFlags(_theFlags:Dictionary):
	updateBreastsCleavage(getBodypartOptionValue(BodypartSlot.Body, "BreastsCleavage", 0.0))
	#if(_theFlags.has("CrotchBulge") && _theFlags["CrotchBulge"]):
		#setBlendshape("CrotchBulge", 1.0)
	#else:
		#setBlendshape("CrotchBulge", 0.0)

func getBodyAlphaMask() -> Texture2D:
	if(getOptionValue("pulledUp", false)):
		return null
	return preload("res://Mesh/Clothing/InmateTop/Textures/Alpha_TankTop.png")

func shouldSubscribeToDollHoleData() -> bool:
	return true

func applyDollHoleData(_data:DollHoleData):
	setBlendshape("BellyBulge", _data.bellyBump)
	#setBlendshape("PussyOpenedWide", _data.vagOpen)
	#setBlendshape("PussyPull", _data.vagPull)
	#setBlendshape("AnusOpenedWide", _data.anusOpen)
	#setBlendshape("AnusPull", _data.anusPull)
