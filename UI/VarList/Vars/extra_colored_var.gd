extends VarUIBase

@onready var option_button: OptionButton = %OptionButton
@onready var color_picker_1: ColorPickerButton = %ColorPicker1
@onready var color_picker_2: ColorPickerButton = %ColorPicker2
@onready var color_picker_3: ColorPickerButton = %ColorPicker3
@onready var color_picker_4: ColorPickerButton = %ColorPicker4

var values:Array = []
# [["p1", "Piercings 1", 0]
var selectedValue:String = ""
# ["p1", Color.WHITE, ...]

func setData(_data:Dictionary):
	if(_data.has("name")):
		$HBoxContainer/Label.text = _data["name"]
	if(_data.has("tooltip")):
		tooltip_text = _data["tooltip"]
	if(_data.has("values")):
		values = _data["values"]
	if(_data.has("value")):
		var am:int = _data["value"].size()
		selectedValue = _data["value"][0] if am > 0 else ""
		color_picker_1.color = _data["value"][1] if am > 1 else Color.WHITE
		color_picker_2.color = _data["value"][2] if am > 2 else Color.WHITE
		color_picker_3.color = _data["value"][3] if am > 3 else Color.WHITE
		color_picker_4.color = _data["value"][4] if am > 4 else Color.WHITE
	updateValues()
	updateSelectedValue()

func updateValues():
	option_button.clear()
	var _i:int = 0
	var found:bool = false
	for entry in values:
		option_button.add_item(entry[1])
		if(entry[0] == selectedValue):
			option_button.select(_i)
			found = true
		_i += 1
	if(!found):
		option_button.add_item(str(selectedValue) if selectedValue != "" else "-NOTHING-")
		option_button.select(_i)

func getAmountOfColors() -> int:
	var theEntry:Array = ["", "", 0]
	for entry in values:
		if(entry[0] == selectedValue):
			theEntry = entry
			break
	var amountOfColors:int = theEntry[2] if theEntry.size() > 2 else 0
	return amountOfColors

func updateSelectedValue():
	var amountOfColors:int = getAmountOfColors()
	color_picker_1.visible = amountOfColors >= 1
	color_picker_2.visible = amountOfColors >= 2
	color_picker_3.visible = amountOfColors >= 3
	color_picker_4.visible = amountOfColors >= 4

func getFinalValue() -> Array:
	var result:Array = [selectedValue]
	var amountOfColors:int = getAmountOfColors()
	if(amountOfColors >= 1):
		result.append(color_picker_1.color)
	if(amountOfColors >= 2):
		result.append(color_picker_2.color)
	if(amountOfColors >= 3):
		result.append(color_picker_3.color)
	if(amountOfColors >= 4):
		result.append(color_picker_4.color)
	return result

func _on_option_button_item_selected(index: int) -> void:
	if(index < 0 || index >= values.size()):
		return
	
	selectedValue = values[index][0]
	updateSelectedValue()
	triggerChange(getFinalValue())
	
func _on_color_picker_1_color_changed(_color: Color) -> void:
	triggerChange(getFinalValue())

func _on_color_picker_2_color_changed(_color: Color) -> void:
	triggerChange(getFinalValue())

func _on_color_picker_3_color_changed(_color: Color) -> void:
	triggerChange(getFinalValue())

func _on_color_picker_4_color_changed(_color: Color) -> void:
	triggerChange(getFinalValue())

func getValue():
	return getFinalValue()
