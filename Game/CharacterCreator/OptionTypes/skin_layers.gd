extends HBoxContainer

var id:String = ""
@onready var label = $Label
@onready var layerList = $VBoxContainer/VBoxContainer
var skinLayerScene = preload("res://Game/CharacterCreator/OptionTypes/SubElements/skin_layer.tscn")
var idToLayer = {}

var customPossibleValues = {}
var values = [
]
var maxLayers = 99
# { id="", color=Color.WHITE, color2, color3}
#var possibleSkins = []
var skinType = TextureType.PartSkin
var skinSubType = TextureSubType.Generic

signal onValueChange(id, newValue)

func setLabel(newLabel:String):
	label.text = newLabel

func setValues(_newVals):
	pass
	#possibleSkins = _newVals

func setData(data:Dictionary):
	if(data.has("skinType")):
		skinType = data["skinType"]
	if(data.has("skinSubType")):
		skinSubType = data["skinSubType"]
	if(data.has("maxLayers")):
		maxLayers = data["maxLayers"]
	if(data.has("customPossibleValues")):
		customPossibleValues = data["customPossibleValues"]
	if(data.has("values")):
		setValues(data["values"])
	updateValues()

func getValue():
	return values

func setValue(newValue):
	values = newValue.duplicate()
	updateValues()

func _on_item_list_item_selected(index):
	if(index < 0 || index >= values.size()):
		return
	
	emit_signal("onValueChange", id, values[index])

func updateValues():
	Util.delete_children(layerList)
	idToLayer.clear()
	
	if(!customPossibleValues.is_empty()):
		var possibleSkinValues = []
		for texture_path in customPossibleValues:
			var textureData = customPossibleValues[texture_path]
			#{name="asd"}
			possibleSkinValues.append([texture_path, textureData["name"]])
		
		var _i = 0
		for layerInfo in values:
			var newSkinlayer = skinLayerScene.instantiate()
			layerList.add_child(newSkinlayer)
			
			newSkinlayer.id = _i
			idToLayer[_i] = newSkinlayer
			newSkinlayer.setValues(possibleSkinValues)
			newSkinlayer.setItemListValue(layerInfo["id"])
			newSkinlayer.setColor(layerInfo["color"])
			newSkinlayer.setColor2(layerInfo["color2"] if layerInfo.has("color2") else Color.WHITE)
			newSkinlayer.setColor3(layerInfo["color3"] if layerInfo.has("color3") else Color.WHITE)
			newSkinlayer.setColorsAmount(1)
			if(customPossibleValues[layerInfo["id"]].has("pattern") && customPossibleValues[layerInfo["id"]]["pattern"]):
				layerInfo["isPattern"] = true
				newSkinlayer.setColorsAmount(3)
			else:
				layerInfo["isPattern"] = false
			newSkinlayer.onDataChanged.connect(onSkinlayerDataChanged)
			newSkinlayer.onDelButton.connect(onSkinlayerDelPressed)
			newSkinlayer.onDownButton.connect(onSkinDownButton)
			newSkinlayer.onUpButton.connect(onSkinUpButton)
			_i += 1
		return
	
	var possibleSkinValues = []
	for texID in GlobalRegistry.getTextureVariants(skinType, skinSubType):
		var textureVariant:TextureVariant = GlobalRegistry.getTextureVariant(skinType, skinSubType, texID)
		possibleSkinValues.append([texID, textureVariant.getVisibleName()])#, textureVariant.getPreviewTexturePath()])
	
	var _i = 0
	for layerInfo in values:
		var newSkinlayer = skinLayerScene.instantiate()
		layerList.add_child(newSkinlayer)
		
		newSkinlayer.id = _i
		idToLayer[_i] = newSkinlayer
		newSkinlayer.setValues(possibleSkinValues)
		newSkinlayer.setItemListValue(layerInfo["id"])
		newSkinlayer.setColor(layerInfo["color"])
		newSkinlayer.setColor2(layerInfo["color2"] if layerInfo.has("color2") else Color.WHITE)
		newSkinlayer.setColor3(layerInfo["color3"] if layerInfo.has("color3") else Color.WHITE)
		newSkinlayer.setColorsAmount(1)
		if(false):
			layerInfo["isPattern"] = true
			newSkinlayer.setColorsAmount(3)
		else:
			layerInfo["isPattern"] = false
		newSkinlayer.onDataChanged.connect(onSkinlayerDataChanged)
		newSkinlayer.onDelButton.connect(onSkinlayerDelPressed)
		newSkinlayer.onDownButton.connect(onSkinDownButton)
		newSkinlayer.onUpButton.connect(onSkinUpButton)
		_i += 1

func onSkinlayerDelPressed(index):
	values.remove_at(index)
	updateValues()
	checkCanAdd()
	emit_signal("onValueChange", id, values.duplicate())

func onSkinDownButton(index):
	Util.moveValueDown(values, index)
	updateValues()
	emit_signal("onValueChange", id, values.duplicate())

func onSkinUpButton(index):
	Util.moveValueUp(values, index)
	updateValues()
	emit_signal("onValueChange", id, values.duplicate())

func onSkinlayerDataChanged(index, newItemID, newColor, newColor2, newColor3):
	values[index]["id"] = newItemID
	values[index]["color"] = newColor
	values[index]["color2"] = newColor2
	values[index]["color3"] = newColor3
	if(!customPossibleValues.is_empty()):
		values[index]["isPattern"] = (customPossibleValues[newItemID].has("pattern") && customPossibleValues[newItemID]["pattern"])
	else:
		values[index]["isPattern"] = false
	
	if(values[index]["isPattern"]):
		idToLayer[index].setColorsAmount(3)
	else:
		idToLayer[index].setColorsAmount(1)
	#print(values)
	emit_signal("onValueChange", id, values.duplicate())

func _on_add_layer_button_pressed():
	if(!customPossibleValues.is_empty()):
		var newId = customPossibleValues.keys()[0]
		values.append({
			id = newId,
			color = Color.WHITE,
			color2 = Color.WHITE,
			color3 = Color.WHITE,
			isPattern=(customPossibleValues[newId].has("pattern") && customPossibleValues[newId]["pattern"]),
		})
	else:
		values.append({
			id = GlobalRegistry.getTextureVariants(skinType, skinSubType).keys()[0],
			color = Color.WHITE,
			color2 = Color.WHITE,
			color3 = Color.WHITE,
			isPattern=false,
		})
	updateValues()
	checkCanAdd()
	emit_signal("onValueChange", id, values.duplicate())

func checkCanAdd():
	var valuesAmount = values.size()
	if(valuesAmount >= maxLayers):
		$VBoxContainer/AddLayerButton.disabled = true
	else:
		$VBoxContainer/AddLayerButton.disabled = false
