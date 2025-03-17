extends Control

@onready var parts_sel_button: Button = %PartsSelButton
@onready var options_sel_button: Button = %OptionsSelButton
@onready var skin_sel_button: Button = %SkinSelButton
var currentTab:String = "parts" # parts options skin

@onready var parts_tab: VBoxContainer = %PartsTab
@onready var parts_list: VBoxContainer = %PartsList

@onready var options_tab: VBoxContainer = %OptionsTab
@onready var options_big_list: VBoxContainer = %OptionsBigList

@onready var skin_tab: VBoxContainer = %SkinTab
@onready var skin_options_big_list: VBoxContainer = %SkinOptionsBigList

var dropdownVarScene := preload("res://UI/VarList/Vars/dropdown_var.tscn")

var collapseRegionScene := preload("res://UI/collapsable_region.tscn")
var varListScene := preload("res://UI/VarList/VarList.tscn")
var regionRememberOpen:Dictionary = {}

var character:BaseCharacter

signal onConfirmPressed

func _ready() -> void:
	#updateSelectedTab()
	#updatePartOptionsList()
	pass

func setCharacter(newChar:BaseCharacter):
	if(character != null && is_instance_valid(character)):
		character.onGenericPartChange.disconnect(onCharGenericPartChange)
		character.onBaseSkinTypeChange.disconnect(onCharBaseSkinDataChange)
		character.onBodypartSkinTypeChange.disconnect(onCharBodypartSkinDataChange)
		character.onBodypartSkinTypeOverrideSwitch.disconnect(onCharBodypartSkinDataOverrideSwitch)
	character = newChar
	if(character != null && is_instance_valid(character)):
		character.onGenericPartChange.connect(onCharGenericPartChange)
		character.onBaseSkinTypeChange.connect(onCharBaseSkinDataChange)
		character.onBodypartSkinTypeChange.connect(onCharBodypartSkinDataChange)
		character.onBodypartSkinTypeOverrideSwitch.connect(onCharBodypartSkinDataOverrideSwitch)
	
	updateSelectedTab()
	updatePartsList()
	updatePartOptionsList()

func getChar() -> BaseCharacter:
	return character

func getCharacter() -> BaseCharacter:
	return character

func onCharBodypartSkinDataOverrideSwitch(_slot):
	updateSkinTab()

func onCharBodypartSkinDataChange(_slot, _skinType, _skinTypeData):
	#updateSkinTab()
	pass

func onCharBaseSkinDataChange(_skinType, _skinTypeData):
	#updateSkinTab()
	pass

func onCharGenericPartChange(_genericType, _id, _newpart):
	updatePartOptionsList()

func updateSelectedTab():
	parts_sel_button.text = "[ Parts ]" if currentTab == "parts" else "Parts"
	options_sel_button.text = "[ Options ]" if currentTab == "options" else "Options"
	skin_sel_button.text = "[ Skin&Colors ]" if currentTab == "skin" else "Skin&Colors"
	
	parts_tab.visible = (currentTab == "parts")
	options_tab.visible = (currentTab == "options")
	skin_tab.visible = (currentTab == "skin")
	
func _on_parts_sel_button_pressed() -> void:
	currentTab = "parts"
	updateSelectedTab()

func _on_options_sel_button_pressed() -> void:
	currentTab = "options"
	updateSelectedTab()

func _on_skin_sel_button_pressed() -> void:
	currentTab = "skin"
	updateSelectedTab()
	updateSkinTab()

func updateSkinTab():
	updatePartOptionsListGeneric(skin_options_big_list, "skin")

func chanceSkinTypeDataColor(theColor:Color, skinType:String):
	if(character == null):
		return
	
	var skinTypes:Dictionary = character.getAllUsedSkinTypes()
	if(!skinTypes.has(skinType)):
		return
	
	var skinTypeData:SkinTypeData = skinTypes[skinType].makeCopy()
	skinTypeData.color = theColor
	#character.triggerUpdateAllSkinTypes()

	GM.characterRegistry.askCharacterChangeBaseSkinTypeData(character, skinType, skinTypeData)
	

func chanceSkinTypeDataBodypartColor(theColor:Color, bodypartSlot:String):
	if(character == null):
		return
	
	var bodypart:BodypartBase = character.getBodypart(bodypartSlot)
	if(bodypart.skinDataOverride == null):
		return
	var newSkinData:SkinTypeData = bodypart.skinDataOverride.makeCopy()
	#bodypart.skinDataOverride.color = theColor
	#character.triggerUpdateAllSkinTypes()
	newSkinData.color = theColor
	GM.characterRegistry.askCharacterBodypartSkinTypeChange(character, bodypartSlot, newSkinData.skinType, newSkinData)

func onSkinTypeOverrideSelected(skinTypeIndex:int, bodypartSlot:String):
	if(character == null):
		return
	
	var bodypart:BodypartBase = character.getBodypart(bodypartSlot)

	var selectedSkinType:String = bodypart.getSupportedSkinTypes().keys()[skinTypeIndex]
	var newSkinTypeData:SkinTypeData = null
	if(bodypart.skinDataOverride != null):
		newSkinTypeData = bodypart.skinDataOverride.makeCopy()
		newSkinTypeData.skinType = selectedSkinType
	GM.characterRegistry.askCharacterBodypartSkinTypeChange(character, bodypartSlot, selectedSkinType, newSkinTypeData)
	#bodypart.skinType = selectedSkinType
	#if(bodypart.skinDataOverride != null):
	#	bodypart.skinDataOverride.skinType = selectedSkinType
	#character.updateAllSkinTypes()
	updateSkinTab()

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
		GM.characterRegistry.askCharacterPartChange(character, BaseCharacter.GENERIC_BODYPARTS, _id, "", {})
		#character.clearBodypart(_id)
		return
	
	#var newBodypart:BodypartBase = GlobalRegistry.createBodypart(_value)
	#if(newBodypart == null):
	#	return
	#character.addBodypart(_id, newBodypart)
	GM.characterRegistry.askCharacterPartChange(character, BaseCharacter.GENERIC_BODYPARTS, _id, _value, {})

func updatePartOptionsList():
	updatePartOptionsListGeneric(options_big_list, "part")

func updatePartOptionsListGeneric(listNode:Node, optionFilter:String):
	Util.delete_children(listNode)
	
	var isSkin:bool = (optionFilter == "skin")
	
	if(character == null):
		return
	
	if(isSkin):
		var skinTypes:Dictionary = character.getAllUsedSkinTypes()
		
		if(!skinTypes.is_empty()):
			var baseSkinRegion := collapseRegionScene.instantiate()
			listNode.add_child(baseSkinRegion)
			baseSkinRegion.setName("Base colors")
			baseSkinRegion.setOpened(regionRememberOpen["baseColors"] if regionRememberOpen.has("baseColors") else false)
			baseSkinRegion.onOpenToggle.connect(onCollapseOpenToggle.bind("baseColors"))
			
			for skinType in skinTypes:
				var skinTypeData:SkinTypeData = skinTypes[skinType]
				
				var skinTypeName:String = SkinType.getName(skinType)
				
				var theLabel:Label = Label.new()
				baseSkinRegion.addNodeInside(theLabel)
				theLabel.text = skinTypeName

				var theColorPicker:ColorPickerButton = ColorPickerButton.new()
				baseSkinRegion.addNodeInside(theColorPicker)
				theColorPicker.color = skinTypeData.color
				theColorPicker.custom_minimum_size.y = 30.0
				
				theColorPicker.color_changed.connect(chanceSkinTypeDataColor.bind(skinType))

	
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
		
		var shouldAddStuff:bool = false
		if(!options.is_empty() || (isSkin && bodypart.supportsSkinTypes())):
			shouldAddStuff = true
		
		if(!shouldAddStuff):
			continue
		
		var newRegion = collapseRegionScene.instantiate()
		listNode.add_child(newRegion)
		newRegion.setName(bodypart.getEditorName())
		newRegion.setOpened(regionRememberOpen[bodypartSlot+"_part"] if regionRememberOpen.has(bodypartSlot+"_part") else false)
		newRegion.onOpenToggle.connect(onCollapseOpenToggle.bind(bodypartSlot+"_part"))
		
		if(isSkin):
			var supportsSkinType:bool = bodypart.supportsSkinTypes()
			
			if(supportsSkinType):
				var possibleSkinTypes:Array = bodypart.getSupportedSkinTypes().keys()
				var theDropDown:OptionButton = OptionButton.new()
				newRegion.addNodeInside(theDropDown)
				theDropDown.item_selected.connect(onSkinTypeOverrideSelected.bind(bodypartSlot))
				
				var _i:int = 0
				for theSkinType in possibleSkinTypes:
					theDropDown.add_item(SkinType.getName(theSkinType))
					if(theSkinType == bodypart.getSkinType()):
						theDropDown.select(_i)
					_i += 1
				
				var isInherit:bool = (bodypart.skinDataOverride == null)
				
				var overrideCheckbox:CheckBox = CheckBox.new()
				newRegion.addNodeInside(overrideCheckbox)
				overrideCheckbox.text = "Inherit base color"
				overrideCheckbox.set_pressed_no_signal(isInherit)
				overrideCheckbox.toggled.connect(onBodypartOverrideSkinDataCheckbox.bind(bodypartSlot))
				
				if(!isInherit):
					var theColorPicker:ColorPickerButton = ColorPickerButton.new()
					newRegion.addNodeInside(theColorPicker)
					theColorPicker.color = bodypart.skinDataOverride.color
					theColorPicker.custom_minimum_size.y = 30.0
					
					theColorPicker.color_changed.connect(chanceSkinTypeDataBodypartColor.bind(bodypartSlot))

				
		var newVarList:VarList = varListScene.instantiate()
		newRegion.addNodeInside(newVarList)
		newVarList.setVars(options)
		newVarList.onVarChange.connect(onBodypartChangeOption.bind(bodypartSlot))

func onBodypartOverrideSkinDataCheckbox(newToggled:bool, bodypartSlot:String):
	var bodypart:BodypartBase = character.getBodypart(bodypartSlot)
	if(newToggled):
		#bodypart.skinDataOverride = null
		GM.characterRegistry.askCharacterBodypartSkinTypeChange(character, bodypartSlot, bodypart.skinType, null)
	else:
		if(bodypart.skinDataOverride == null):
			#bodypart.skinDataOverride = SkinTypeData.new()
			#bodypart.skinDataOverride.skinType = bodypart.getSkinType()
			var newSkinTypeData:SkinTypeData = SkinTypeData.new()
			newSkinTypeData.skinType = bodypart.getSkinType()
			GM.characterRegistry.askCharacterBodypartSkinTypeChange(character, bodypartSlot, newSkinTypeData.skinType, newSkinTypeData)
	updateSkinTab()
	#character.updateAllSkinTypes()
	

func onCollapseOpenToggle(newOpen:bool, collapseID:String):
	regionRememberOpen[collapseID] = newOpen

func onBodypartChangeOption(_id:String, value, bodypartSlot:String):
	var bodypart:BodypartBase = character.getBodypart(bodypartSlot)
	if(bodypart == null):
		return
	#bodypart.setOptionValue(_id, value)
	GM.characterRegistry.askCharacterPartOptionChange(character, BaseCharacter.GENERIC_BODYPARTS, bodypartSlot, _id, value)


func _on_confirm_button_pressed() -> void:
	onConfirmPressed.emit()

func _enter_tree() -> void:
	UIHandler.addUI(self)

func _exit_tree() -> void:
	UIHandler.removeUI(self)
