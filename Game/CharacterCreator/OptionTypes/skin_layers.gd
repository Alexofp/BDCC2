extends HBoxContainer

var id:String = ""
@onready var label = $Label
@onready var layerList = $VBoxContainer/VBoxContainer
var skinLayerScene = preload("res://Game/CharacterCreator/OptionTypes/SubElements/skin_layer.tscn")

var values = [
]
var maxLayers = 4
# { id="", color=Color.WHITE}
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
	if(data.has("values")):
		setValues(data["values"])
	if(data.has("skinType")):
		skinType = data["skinType"]
	if(data.has("skinSubType")):
		skinSubType = data["skinSubType"]
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
	
	var possibleSkinValues = []
	for texID in GlobalRegistry.getTextureVariants(skinType, skinSubType):
		var textureVariant:TextureVariant = GlobalRegistry.getTextureVariant(skinType, skinSubType, texID)
		possibleSkinValues.append([texID, textureVariant.getVisibleName()])#, textureVariant.getPreviewTexturePath()])
	
	var _i = 0
	for layerInfo in values:
		var newSkinlayer = skinLayerScene.instantiate()
		layerList.add_child(newSkinlayer)
		
		newSkinlayer.id = _i
		newSkinlayer.setValues(possibleSkinValues)
		newSkinlayer.setItemListValue(layerInfo["id"])
		newSkinlayer.setColor(layerInfo["color"])
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

func onSkinlayerDataChanged(index, newItemID, newColor):
	values[index]["id"] = newItemID
	values[index]["color"] = newColor
	#print(values)
	emit_signal("onValueChange", id, values.duplicate())

func _on_add_layer_button_pressed():
	values.append({
		id = GlobalRegistry.getTextureVariants(skinType, skinSubType).keys()[0],
		color = Color.WHITE,
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
