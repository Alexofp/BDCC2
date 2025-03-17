extends VarUIBase

@onready var layer_list: VBoxContainer = %LayerList

var texType:String = ""
var texSubType:String = ""

var layers:Array = []

var texVarLayerVarScene = preload("res://UI/VarList/Vars/texture_variant_layer_var.tscn")

func setData(_data:Dictionary):
	if(_data.has("name")):
		$Label.text = _data["name"]
	if(_data.has("tooltip")):
		tooltip_text = _data["tooltip"]
	if(_data.has("texType")):
		texType = _data["texType"]
	if(_data.has("texSubType")):
		texSubType = _data["texSubType"]
	if(_data.has("value")):
		layers = _data["value"].duplicate(true)
	
	updateLayers()

func updateLayers():
	Util.delete_children(layer_list)
	
	var _i:int = 0
	for layerEntry in layers:
		var newVarScene = texVarLayerVarScene.instantiate()
		layer_list.add_child(newVarScene)
		
		newVarScene.setData({
			value = layerEntry,
			texType = texType,
			texSubType = texSubType,
		})
		
		newVarScene.onValueChange.connect(onTexLayerChanged.bind(_i))
		newVarScene.onUpButtonPressed.connect(onTexLayerUpPressed.bind(_i))
		newVarScene.onDownButtonPressed.connect(onTexLayerDownPressed.bind(_i))
		newVarScene.onDeleteButtonPressed.connect(onTexLayerDeletePressed.bind(_i))
		
		_i += 1

func onTexLayerDeletePressed(_indx:int):
	layers.remove_at(_indx)
	updateLayers()
	triggerChange(layers.duplicate(true))

func onTexLayerUpPressed(_indx:int):
	Util.moveValueUp(layers, _indx)
	updateLayers()
	triggerChange(layers.duplicate(true))

func onTexLayerDownPressed(_indx:int):
	Util.moveValueDown(layers, _indx)
	updateLayers()
	triggerChange(layers.duplicate(true))

func onTexLayerChanged(_id, _value, _indx:int):
	layers[_indx] = _value
	
	triggerChange(layers.duplicate(true))


func _on_add_button_pressed() -> void:
	var allIDs:Array = GlobalRegistry.getTextureVariantsIDsOfTypeAndSubType(texType, texSubType)
	
	if(allIDs.is_empty()):
		return
	
	var pickedID:String = allIDs.front()
	var theTexVariant:TextureVariant = GlobalRegistry.getTextureVariant(pickedID)
	if(theTexVariant == null):
		return
	
	var newLayer:Dictionary = {
		id = allIDs.front(),
		colorR = theTexVariant.getFlag("defR", Color.WHITE),
		colorG = theTexVariant.getFlag("defG", Color.DARK_GRAY),
		colorB = theTexVariant.getFlag("defB", Color.DIM_GRAY),
	}
	layers.append(newLayer)
	updateLayers()
	
	triggerChange(layers.duplicate(true))
