extends PanelContainer

@onready var label = $PartVBox/HBoxContainer/Label
@onready var partOptionsList = $PartVBox/PartOptions
@onready var childPartsList = $PartVBox/ChildPartsList

var bodypartGroup = preload("res://Game/CharacterCreator/Elements/bodypart_group.tscn")
var groups = {}

var editingBodypart
var numberSliderScene = preload("res://Game/CharacterCreator/OptionTypes/number_slider.tscn")
var typeSelectorScene = preload("res://Game/CharacterCreator/OptionTypes/type_selector.tscn")
var colorSelectorScene = preload("res://Game/CharacterCreator/OptionTypes/color.tscn")
var baseSkinDataScene = preload("res://Game/CharacterCreator/OptionTypes/base_skin_data.tscn")
var checkboxScene = preload("res://Game/CharacterCreator/OptionTypes/checkbox.tscn")
var textureSelectorScene = preload("res://Game/CharacterCreator/OptionTypes/texture_selector.tscn")
var skinLayersScene = preload("res://Game/CharacterCreator/OptionTypes/skin_layers.tscn")
var patternAndColorSelectorScene = preload("res://Game/CharacterCreator/OptionTypes/pattern_and_colors_selector.tscn")
var extraAdderScene = preload("res://Game/CharacterCreator/OptionTypes/extra_adder.tscn")

signal onChildBodypartChangeType(part, slot, newtype)
signal onDeleteButtonPressed(part)
signal onAddingExtraButtonPressed(part, newextraid)

var editType = "part"

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
	if(type == "patternAndColors"):
		return patternAndColorSelectorScene.instantiate()
	
	return null

func _ready():
	setShowDeleteButton(false)

func setLabel(newLabel:String):
	label.text = newLabel

func setShowDeleteButton(theShouldShow):
	if(theShouldShow):
		$PartVBox/HBoxContainer/DeleteButton.visible = true
	else:
		$PartVBox/HBoxContainer/DeleteButton.visible = false

func setBodypart(newBodypart):
	editingBodypart = newBodypart
	
	updateOptions()

func updateOptions():
	Util.delete_children(partOptionsList)
	Util.delete_children(childPartsList)
	groups = {}
	
	if(editingBodypart == null):
		return
	
	var options = {}
	
	var rawOptions = editingBodypart.getOptions()
	for optionID in rawOptions:
		var theOption = rawOptions[optionID]
		var optionKind = ["part"]
		if(theOption.has("menu")):
			if(theOption["menu"] is String):
				optionKind = [theOption["menu"]]
			else:
				optionKind = theOption["menu"]
		if(editType in optionKind):
			options[optionID] = theOption
	
	# Adding an extra widget for the skin menu
	if(editType == "skin"):
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
			Log.Printerr("Couldn't create an option for type "+str(optionInfo["type"]))
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
		newOptionScene.setValue(editingBodypart.getOptionValue(optionID))
		newOptionScene.onValueChange.connect(onOptionSceneValueChanged)
	
	# Adding an extra widgets for picking parts
	if(editType != "part" || !(editingBodypart is BaseBodypart)):
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
	
	# Also adding an extra picking widget for the parts one
	var extrasIDs = GlobalRegistry.getExtraPartIDsForBodypartID(editingBodypart.id)
	if(extrasIDs.size() > 0):
		var extraAdder = extraAdderScene.instantiate()
		childPartsList.add_child(extraAdder)
		extraAdder.id = "extraAdder"
		
		extraAdder.setLabel("Extras:")
		
		var extraValues = []
		for possiblePartID in extrasIDs:
			var otherPart:BodypartExtra = GlobalRegistry.getExtraPartRef(possiblePartID)
			if(otherPart == null):
				continue
			extraValues.append([otherPart.id, otherPart.getVisibleName()])
		
		extraAdder.setValues(extraValues)

		#extraAdder.onValueChange.connect(onChildPartSlotSceneChangeType)
		extraAdder.onAddButton.connect(onExtraAdderAdded)

func onExtraAdderAdded(_id, newExtraID):
	emit_signal("onAddingExtraButtonPressed", editingBodypart, newExtraID)

func onOptionSceneValueChanged(id, newValue):
	if(editingBodypart == null):
		return
	editingBodypart.setOptionValue(id, newValue)
	
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

func _on_delete_button_pressed():
	emit_signal("onDeleteButtonPressed", editingBodypart)
