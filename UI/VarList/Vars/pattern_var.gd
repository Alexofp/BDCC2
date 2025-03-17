extends VarUIBase

@onready var dropdown_var: VBoxContainer = $HBoxContainer/DropdownVar
@onready var color_picker_r: ColorPickerButton = %ColorPickerR
@onready var color_picker_g: ColorPickerButton = %ColorPickerG
@onready var color_picker_b: ColorPickerButton = %ColorPickerB
@onready var color_list: HBoxContainer = %ColorList

var texType:String = ""
var texSubType:String = ""

var data:Dictionary = {
	pattern = "",
	colorR = Color.WHITE,
	colorG = Color.WHITE,
	colorB = Color.WHITE,
}

func setData(_data:Dictionary):
	var theName:String = "Pattern"
	if(_data.has("name")):
		theName = _data["name"]
	if(_data.has("tooltip")):
		tooltip_text = _data["tooltip"]
	if(_data.has("alpha")):
		color_picker_r.edit_alpha = _data["alpha"]
		color_picker_g.edit_alpha = _data["alpha"]
		color_picker_b.edit_alpha = _data["alpha"]
	if(_data.has("texType")):
		texType = _data["texType"]
	if(_data.has("texSubType")):
		texSubType = _data["texSubType"]
	if(_data.has("value")):
		data = _data["value"].duplicate()
		
	dropdown_var.setData({
		name = theName,
		value = data["pattern"] if data.has("pattern") else "",
		values = getTextureVariantsValues(texType, texSubType),
	})
	updateColorPickers()
	updateColorPickerColors()

func getTextureVariantsValues(theTexType:String, theTexSubType:String) -> Array:
	var result:Array = []
	
	var texVarIDs:Array = GlobalRegistry.getTextureVariantsIDsOfTypeAndSubType(theTexType, theTexSubType)
	
	for texVarID in texVarIDs:
		var textureVariant:TextureVariant = GlobalRegistry.getTextureVariant(texVarID)
		if(textureVariant == null):
			continue
		result.append([texVarID, textureVariant.getName()])
		
	return result

func updateColorPickers():
	var textureVariant:TextureVariant = GlobalRegistry.getTextureVariant(data["pattern"] if data.has("pattern") else "")
	if(textureVariant == null):
		color_picker_r.visible = false
		color_picker_g.visible = false
		color_picker_b.visible = false
		return
	
	color_picker_r.visible = textureVariant.getFlag("hasR", true)
	color_picker_g.visible = textureVariant.getFlag("hasG", true)
	color_picker_b.visible = textureVariant.getFlag("hasB", true)
	color_list.visible = (color_picker_r.visible || color_picker_g.visible || color_picker_b.visible)

func updateColorPickerColors():
	color_picker_r.color = data["colorR"] if data.has("colorR") else Color.WHITE
	color_picker_g.color = data["colorG"] if data.has("colorG") else Color.WHITE
	color_picker_b.color = data["colorB"] if data.has("colorB") else Color.WHITE

func _on_dropdown_var_on_value_change(_id: Variant, newValue: Variant) -> void:
	data["pattern"] = newValue
	
	updateColorPickers()
	triggerChange(data.duplicate())

func _on_color_picker_r_color_changed(color: Color) -> void:
	data["colorR"] = color
	triggerChange(data.duplicate())

func _on_color_picker_g_color_changed(color: Color) -> void:
	data["colorG"] = color
	triggerChange(data.duplicate())

func _on_color_picker_b_color_changed(color: Color) -> void:
	data["colorB"] = color
	triggerChange(data.duplicate())
