extends VBoxContainer

var id:String = ""
@onready var label = $HBoxContainer2/Label
@onready var optionButton = $HBoxContainer2/OptionButton
@onready var colPick1 = $HBoxContainer/ColorPickerButton
@onready var colPick2 = $HBoxContainer/ColorPickerButton2
@onready var colPick3 = $HBoxContainer/ColorPickerButton3

var skinType = TextureType.Pattern
var skinSubType = TextureSubType.Generic

var values = []

signal onValueChange(id, newValue)

func setLabel(newLabel:String):
	label.text = newLabel

func setValues(newValues):
	optionButton.clear()
	values = []
	for valueInfo in newValues:
		if(valueInfo is Array):
			values.append(valueInfo[0])
			optionButton.add_item(valueInfo[1])
		else:
			values.append(valueInfo)
			optionButton.add_item(str(valueInfo))
	if(values.size() > 0):
		optionButton.selected = 0

func updateValues():
	optionButton.clear()
	values = []
	for texID in GlobalRegistry.getTextureVariants(skinType, skinSubType):
		var textureVariant:TextureVariant = GlobalRegistry.getTextureVariant(skinType, skinSubType, texID)
		values.append(texID)
		optionButton.add_item(textureVariant.getVisibleName())
		#possibleSkinValues.append([texID, textureVariant.getVisibleName()])#, textureVariant.getPreviewTexturePath()])
	if(values.size() > 0):
		optionButton.selected = 0

func setData(data:Dictionary):
	if(data.has("values")):
		#setValues(data["values"])
		pass
	if(data.has("skinType")):
		skinType = data["skinType"]
	if(data.has("skinSubType")):
		skinSubType = data["skinSubType"]
	updateValues()

func getValue():
	var selectedIndex = optionButton.selected
	
	if(selectedIndex < 0 || selectedIndex >= values.size()):
		return null
	
	return [values[selectedIndex], colPick1.color, colPick2.color, colPick3.color]

func setValue(newValue):
	for _i in range(values.size()):
		if(values[_i] == newValue[0]):
			optionButton.selected = _i
			break
	colPick1.color = newValue[1]
	colPick2.color = newValue[2]
	colPick3.color = newValue[3]

func _on_option_button_item_selected(index):
	if(index < 0 || index >= values.size()):
		return
	
	emit_signal("onValueChange", id, [values[index], colPick1.color, colPick2.color, colPick3.color])


func _on_color_picker_button_color_changed(_color):
	var index = optionButton.selected
	if(index < 0 || index >= values.size()):
		return
	emit_signal("onValueChange", id, [values[index], colPick1.color, colPick2.color, colPick3.color])
