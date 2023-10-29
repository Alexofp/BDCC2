extends PanelContainer

@onready var label = $PartVBox/Label
@onready var partOptionsList = $PartVBox/PartOptions
@onready var childPartsList = $PartVBox/ChildPartsList

var parentPart: BaseBodypart
var parentPartSlot

var bodypartGroup = preload("res://Game/CharacterCreator/Elements/bodypart_group.tscn")
var groups = {}

var editingBodypart: BaseBodypart
var numberSliderScene = preload("res://Game/CharacterCreator/OptionTypes/number_slider.tscn")
var typeSelectorScene = preload("res://Game/CharacterCreator/OptionTypes/type_selector.tscn")
var colorSelectorScene = preload("res://Game/CharacterCreator/OptionTypes/color.tscn")
var baseSkinDataScene = preload("res://Game/CharacterCreator/OptionTypes/base_skin_data.tscn")
var checkboxScene = preload("res://Game/CharacterCreator/OptionTypes/checkbox.tscn")
var textureSelectorScene = preload("res://Game/CharacterCreator/OptionTypes/texture_selector.tscn")
var skinLayersScene = preload("res://Game/CharacterCreator/OptionTypes/skin_layers.tscn")

signal onChildBodypartChangeType(part, slot, newtype)

var isSkinOptions = false

func createOptionScene(type:String) -> Control:
	if(type == "slider"):
		return numberSliderScene.instantiate()
	if(type == "list"):
		return typeSelectorScene.instantiate()
	if(type == "color"):
		return colorSelectorScene.instantiate()
	if(type == "baseSkinData"):
		return baseSkinDataScene.instantiate()
	if(type == "checkbox"):
		return checkboxScene.instantiate()
	if(type in ["biglist", "textures", "texture"]):
		return textureSelectorScene.instantiate()
	if(type == "layers"):
		return skinLayersScene.instantiate()
	
	return null

func _ready():
	pass

func setLabel(newLabel:String):
	label.text = newLabel

func _on_type_selector_h_box_on_value_change(_id, newValue):
	if(editingBodypart == null):
		emit_signal("onNullBodypartChangeType", parentPart, parentPartSlot, newValue)
		return
	
	emit_signal("onBodypartChangeType", parentPart, parentPartSlot, editingBodypart, newValue)

func setBodypart(newBodypart:BaseBodypart):
	editingBodypart = newBodypart
	
	updateOptions()

func updateOptions():
	Util.delete_children(partOptionsList)
	Util.delete_children(childPartsList)
	groups = {}
	
	if(editingBodypart == null):
		return
	
	var options = []
	if(!isSkinOptions):
		options = editingBodypart.getOptions()
	else:
		# Skin
		options = editingBodypart.getSkinOptions()
		
		if(editingBodypart.supportsUniqueBaseSkinData()):
			var skinCheckboxScene = createOptionScene("checkbox")
			partOptionsList.add_child(skinCheckboxScene)
			skinCheckboxScene.setLabel("Override base skin")
			skinCheckboxScene.onValueChange.connect(onOverrideBaseSkinChanged)
			
			if(editingBodypart.baseSkinDataOverride != null):
				skinCheckboxScene.setValue(true)
				
				var skinScene = createOptionScene("baseSkinData")
				partOptionsList.add_child(skinScene)
				skinScene.setValue(editingBodypart.baseSkinDataOverride)
				skinScene.onValueChange.connect(onBaseSkinDataChanged)
			else:
				skinCheckboxScene.setValue(false)
	
	for optionID in options:
		var optionInfo = options[optionID]
		
		var newOptionScene = createOptionScene(optionInfo["type"])
		if(newOptionScene == null):
			Log.printerr("Couldn't create an option for type "+str(optionInfo["type"]))
			continue
		
		if(optionInfo.has("group") && optionInfo["group"]!=""):
			var groupID = optionInfo["group"]
			if(!groups.has(groupID)):
				var newGroupScene = bodypartGroup.instantiate()
				partOptionsList.add_child(newGroupScene)
				newGroupScene.setLabel(editingBodypart.getGroupInfo(groupID)["name"])
				groups[groupID] = newGroupScene
			groups[groupID].addNewElement(newOptionScene)
		else:
			partOptionsList.add_child(newOptionScene)
		
		newOptionScene.id = optionID
		newOptionScene.setLabel(optionInfo["name"] if optionInfo.has("name") else optionID)
		newOptionScene.setData(optionInfo)
		if(!isSkinOptions):
			newOptionScene.setValue(editingBodypart.getOptionValue(optionID))
		else:
			newOptionScene.setValue(editingBodypart.getSkinOptionValue(optionID))
		newOptionScene.onValueChange.connect(onOptionSceneValueChanged)
	
	if(isSkinOptions):
		return
	for bodypartSlot in editingBodypart.getBodypartSlots():
		var newSlotSelectScene = typeSelectorScene.instantiate()
		childPartsList.add_child(newSlotSelectScene)
		newSlotSelectScene.id = bodypartSlot
		
		newSlotSelectScene.setLabel(BodypartSlot.getVisibleName(bodypartSlot))
		
		var selectorValues = []
		for possiblePartID in ([null]+GlobalRegistry.getBodyparts().keys()):
			if(possiblePartID == null):
				selectorValues.append([null, "Nothing"])
				continue
			var otherPart:BaseBodypart = GlobalRegistry.getBodypartRef(possiblePartID)
			if(otherPart == null):
				continue
			selectorValues.append([otherPart.id, otherPart.getVisibleName()])
		
		newSlotSelectScene.setValues(selectorValues)
		if(editingBodypart.hasBodypart(bodypartSlot)):
			newSlotSelectScene.setValue(editingBodypart.getBodypart(bodypartSlot).id)
		else:
			newSlotSelectScene.setValue(null)
		newSlotSelectScene.onValueChange.connect(onChildPartSlotSceneChangeType)

func onOptionSceneValueChanged(id, newValue):
	if(editingBodypart == null):
		return
	if(!isSkinOptions):
		editingBodypart.setOptionValue(id, newValue)
	else:
		editingBodypart.setSkinOptionValue(id, newValue)
	
func onChildPartSlotSceneChangeType(id, newType):
	emit_signal("onChildBodypartChangeType", editingBodypart, id, newType)

func onOverrideBaseSkinChanged(_id, newValue):
	if(editingBodypart == null):
		return
	if(newValue):
		editingBodypart.setBaseSkinDataOverride(BaseSkinData.new())
	else:
		editingBodypart.setBaseSkinDataOverride(null)
	
	updateOptions()

func onBaseSkinDataChanged(_id, newValue):
	if(editingBodypart == null):
		return
	editingBodypart.setBaseSkinDataOverride(newValue)
