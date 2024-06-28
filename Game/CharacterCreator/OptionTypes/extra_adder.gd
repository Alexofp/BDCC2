extends HBoxContainer

var id:String = ""
@onready var label = $Label
@onready var optionButton = $OptionButton

var values = []

signal onValueChange(id, newValue)
signal onAddButton(id, value)

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

func setData(data:Dictionary):
	if(data.has("values")):
		setValues(data["values"])

func getValue():
	var selectedIndex = optionButton.selected
	
	if(selectedIndex < 0 || selectedIndex >= values.size()):
		return null
	
	return values[selectedIndex]

func setValue(newValue):
	for _i in range(values.size()):
		if(values[_i] == newValue):
			optionButton.selected = _i
			return

func _on_option_button_item_selected(index):
	if(index < 0 || index >= values.size()):
		return
	
	emit_signal("onValueChange", id, values[index])

func _on_add_button_pressed():
	emit_signal("onAddButton", id, getValue())
