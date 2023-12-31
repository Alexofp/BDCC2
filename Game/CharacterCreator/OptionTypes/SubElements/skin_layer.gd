extends HBoxContainer

@onready var itemList = $ItemList
var id
var values = []
signal onDataChanged(id, newItemID, newColor)
signal onDownButton(id)
signal onUpButton(id)
signal onDelButton(id)

func setValues(newValues):
	itemList.clear()
	values = []
	for valueInfo in newValues:
		if(valueInfo is Array):
			values.append(valueInfo[0])
			if(valueInfo.size() > 2):
				itemList.add_icon_item((valueInfo[2] if valueInfo[2] is Texture2D else load(valueInfo[2])), valueInfo[1])
			else:
				itemList.add_item(valueInfo[1])
		else:
			values.append(valueInfo)
			itemList.add_item(str(valueInfo))
	if(values.size() > 0):
		itemList.selected = 0

func setItemListValue(newValue):
	for _i in range(values.size()):
		if(values[_i] == newValue):
			itemList.selected = _i
			return

func getItemListValue():
	var selectedIndex = itemList.selected
	
	if(selectedIndex < 0 || selectedIndex >= values.size()):
		return null
	
	return values[selectedIndex]

func getColor() -> Color:
	return $ColorPickerButton.color

func setColor(newCol:Color):
	$ColorPickerButton.color = newCol

func _on_color_picker_button_color_changed(_color):
	emit_signal("onDataChanged", id, getItemListValue(), getColor())

func _on_item_list_item_selected(_index):
	emit_signal("onDataChanged", id, getItemListValue(), getColor())

func _on_down_button_pressed():
	emit_signal("onDownButton", id)

func _on_up_button_pressed():
	emit_signal("onUpButton", id)

func _on_del_button_pressed():
	emit_signal("onDelButton", id)
