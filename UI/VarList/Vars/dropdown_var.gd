extends VarUIBase

@onready var option_button: OptionButton = $HBoxContainer/OptionButton

var values:Array = []
var selectedValue

func setData(_data:Dictionary):
	if(_data.has("name")):
		$HBoxContainer/Label.text = _data["name"]
	if(_data.has("tooltip")):
		tooltip_text = _data["tooltip"]
	if(_data.has("values")):
		values = _data["values"]
	if(_data.has("value")):
		selectedValue = _data["value"]
	updateValues()

func updateValues():
	option_button.clear()
	var _i:=0
	var foundSelected:bool = false
	for valueLine in values:
		var valueValue = valueLine
		var textValue:String = str(valueLine)
		if(valueLine is Array):
			valueValue = valueLine[0]
			if(valueLine.size() > 1):
				textValue = str(valueLine[1])
			else:
				textValue = str(valueLine[0])
		
		option_button.add_item(textValue)
		if(selectedValue == valueValue):
			option_button.select(_i)
			foundSelected = true
		_i += 1
	
	if(!foundSelected):
		option_button.add_item(str(selectedValue))
		option_button.select(_i)
		_i += 1

func _on_check_box_toggled(toggled_on: bool) -> void:
	triggerChange(toggled_on)

func _on_option_button_item_selected(index: int) -> void:
	if(index < 0 || index >= values.size()):
		return
	
	selectedValue = values[index]
	if(selectedValue is Array):
		selectedValue = selectedValue[0]
	triggerChange(selectedValue)
	
