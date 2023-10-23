extends PanelContainer

@onready var label = $PartVBox/Label
@onready var partOptionsList = $PartVBox/PartOptions
@onready var childPartsList = $PartVBox/ChildPartsList

var parentPart: BaseBodypart
var parentPartSlot

var editingBodypart: BaseBodypart
var numberSliderScene = preload("res://Game/CharacterCreator/OptionTypes/number_slider.tscn")
var typeSelectorScene = preload("res://Game/CharacterCreator/OptionTypes/type_selector.tscn")
var colorSelectorScene = preload("res://Game/CharacterCreator/OptionTypes/color.tscn")
var baseSkinDataScene = preload("res://Game/CharacterCreator/OptionTypes/base_skin_data.tscn")

signal onChildBodypartChangeType(part, slot, newtype)

func createOptionScene(type:String) -> Control:
	if(type == "slider"):
		return numberSliderScene.instantiate()
	if(type == "list"):
		return typeSelectorScene.instantiate()
	if(type == "color"):
		return colorSelectorScene.instantiate()
	if(type == "baseSkinData"):
		return baseSkinDataScene.instantiate()
	
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
	
	if(editingBodypart == null):
		return
	
	var options = editingBodypart.getOptions()
	
	for optionID in options:
		var optionInfo = options[optionID]
		
		var newOptionScene = createOptionScene(optionInfo["type"])
		if(newOptionScene == null):
			Log.printerr("Couldn't create an option for type "+str(optionInfo["type"]))
			continue
		partOptionsList.add_child(newOptionScene)
		
		newOptionScene.id = optionID
		newOptionScene.setLabel(optionInfo["name"] if optionInfo.has("name") else optionID)
		newOptionScene.setData(optionInfo)
		newOptionScene.setValue(editingBodypart.getOptionValue(optionID))
		newOptionScene.onValueChange.connect(onOptionSceneValueChanged)
	
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
	editingBodypart.setOptionValue(id, newValue)
	
func onChildPartSlotSceneChangeType(id, newType):
	emit_signal("onChildBodypartChangeType", editingBodypart, id, newType)
