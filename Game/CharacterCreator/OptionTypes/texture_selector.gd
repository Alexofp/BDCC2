extends HBoxContainer

var id:String = ""
@onready var label = $Label
@onready var itemList = $ItemList

var values = []

signal onValueChange(id, newValue)

func setLabel(newLabel:String):
	label.text = newLabel

func setValues(newValues):
	itemList.clear()
	values = []
	for valueInfo in newValues:
		if(valueInfo is Array):
			values.append(valueInfo[0])
			if(valueInfo.size() > 2):
				var theTexture
				if(valueInfo[2] is String):
					theTexture = load(valueInfo[2])
				else:
					theTexture = valueInfo[2]
				itemList.add_item(valueInfo[1], theTexture)
			else:
				itemList.add_item(valueInfo[1])
		else:
			values.append(valueInfo)
			itemList.add_item(str(valueInfo))
	if(values.size() > 0):
		itemList.select(0)

func setData(data:Dictionary):
	if(data.has("values")):
		setValues(data["values"])
	if(data.has("iconSize")):
		itemList.fixed_icon_size = data["iconSize"]
	if(data.has("iconSscale")):
		itemList.icon_scale = data["iconSscale"]

func getValue():
	var selectedIndex = itemList.selected
	
	if(selectedIndex < 0 || selectedIndex >= values.size()):
		return null
	
	return values[selectedIndex]

func setValue(newValue):
	for _i in range(values.size()):
		if(values[_i] == newValue):
			itemList.select(_i)
			return

func _on_item_list_item_selected(index):
	if(index < 0 || index >= values.size()):
		return
	
	emit_signal("onValueChange", id, values[index])
