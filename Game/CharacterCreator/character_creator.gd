extends Control

@onready var parts_sel_button: Button = %PartsSelButton
@onready var options_sel_button: Button = %OptionsSelButton
@onready var skin_sel_button: Button = %SkinSelButton
var currentTab:String = "parts" # parts options skin

@onready var parts_tab: VBoxContainer = %PartsTab
@onready var parts_list: VBoxContainer = %PartsList

@onready var options_tab: VBoxContainer = %OptionsTab
@onready var options_big_list: VBoxContainer = %OptionsBigList

var dropdownVarScene := preload("res://UI/VarList/Vars/dropdown_var.tscn")

var collapseRegionScene := preload("res://UI/collapsable_region.tscn")
var varListScene := preload("res://UI/VarList/VarList.tscn")
var regionRememberOpen:Dictionary = {}

var character:BaseCharacter

func _ready() -> void:
	#updateSelectedTab()
	#updatePartOptionsList()
	pass

func setCharacter(newChar:BaseCharacter):
	if(character != null && is_instance_valid(character)):
		character.onGenericPartChange.disconnect(onCharGenericPartChange)
	character = newChar
	if(character != null && is_instance_valid(character)):
		character.onGenericPartChange.connect(onCharGenericPartChange)
	
	updateSelectedTab()
	updatePartsList()
	updatePartOptionsList()

func getChar() -> BaseCharacter:
	return character

func getCharacter() -> BaseCharacter:
	return character

func onCharGenericPartChange(_id, _newpart):
	updatePartOptionsList()

func updateSelectedTab():
	parts_sel_button.text = "[ Parts ]" if currentTab == "parts" else "Parts"
	options_sel_button.text = "[ Options ]" if currentTab == "options" else "Options"
	skin_sel_button.text = "[ Skin&Colors ]" if currentTab == "skin" else "Skin&Colors"
	
	parts_tab.visible = (currentTab == "parts")
	options_tab.visible = (currentTab == "options")
	
func _on_parts_sel_button_pressed() -> void:
	currentTab = "parts"
	updateSelectedTab()

func _on_options_sel_button_pressed() -> void:
	currentTab = "options"
	updateSelectedTab()

func _on_skin_sel_button_pressed() -> void:
	currentTab = "skin"
	updateSelectedTab()

func updatePartsList():
	Util.delete_children(parts_list)
	
	if(character == null):
		return
	
	for bodypartSlot in BodypartSlot.getAll():
		var slotName:String = BodypartSlot.getName(bodypartSlot)
		
		var newDropDown := dropdownVarScene.instantiate()
		newDropDown.id = bodypartSlot
		parts_list.add_child(newDropDown)
		
		var values:Array = [
			["", "Nothing"],
		]
		var bodypartIDs:Array = GlobalRegistry.getBodypartIDsForSlot(bodypartSlot)
		for bodypartID in bodypartIDs:
			var bodypartRef:BodypartBase = GlobalRegistry.getBodypartRef(bodypartID)
			values.append([bodypartID, bodypartRef.getEditorName()])
		
		newDropDown.setData({
			name = slotName,
			value = character.getBodypart(bodypartSlot).id if character.hasBodypart(bodypartSlot) else "",
			values = values,
		})
		newDropDown.onValueChange.connect(onBodypartDropdownPicked)

func onBodypartDropdownPicked(_id:String, _value):
	if(_value == null):
		_value = ""
	
	if(_value == ""):
		character.clearBodypart(_id)
		return
	
	var newBodypart:BodypartBase = GlobalRegistry.createBodypart(_value)
	if(newBodypart == null):
		return
	character.addBodypart(_id, newBodypart)

func updatePartOptionsList():
	updatePartOptionsListGeneric(options_big_list, "part")

func updatePartOptionsListGeneric(listNode:Node, optionFilter:String):
	Util.delete_children(listNode)
	
	if(character == null):
		return
	
	for bodypartSlot in character.getBodyparts():
		var bodypart:BodypartBase = character.getBodypart(bodypartSlot)
		
		var allOptions:Dictionary = bodypart.getOptions()
		var options:Dictionary = {}
		for optionID in allOptions:
			var optionEntry:Dictionary = allOptions[optionID]
			var optionTypes:Array = optionEntry["editors"] if optionEntry.has("editors") else ["part"]
			if(!optionTypes.has(optionFilter)):
				continue
			optionEntry["value"] = bodypart.getOptionValue(optionID)
			options[optionID] = optionEntry
		
		var newRegion = collapseRegionScene.instantiate()
		listNode.add_child(newRegion)
		newRegion.setName(bodypart.getEditorName())
		newRegion.setOpened(regionRememberOpen[bodypartSlot+"_part"] if regionRememberOpen.has(bodypartSlot+"_part") else false)
		newRegion.onOpenToggle.connect(onCollapseOpenToggle.bind(bodypartSlot+"_part"))
		
		var newVarList:VarList = varListScene.instantiate()
		newRegion.addNodeInside(newVarList)
		newVarList.setVars(options)
		newVarList.onVarChange.connect(onBodypartChangeOption.bind(bodypartSlot))

func onCollapseOpenToggle(newOpen:bool, collapseID:String):
	regionRememberOpen[collapseID] = newOpen

func onBodypartChangeOption(_id:String, value, bodypartSlot:String):
	var bodypart:BodypartBase = character.getBodypart(bodypartSlot)
	if(bodypart == null):
		return
	bodypart.setOptionValue(_id, value)
