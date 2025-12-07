extends Control

@onready var parts_sel_button: Button = %PartsSelButton
@onready var options_sel_button: Button = %OptionsSelButton
@onready var skin_sel_button: Button = %SkinSelButton
@onready var char_sel_button: Button = %CharSelButton
var currentTab:String = "char" # parts options skin char
var zoneFilter:int = CharCreatorZone.ALL

@onready var parts_tab: VBoxContainer = %PartsTab
@onready var parts_list: VBoxContainer = %PartsList

@onready var options_tab: VBoxContainer = %OptionsTab
@onready var options_big_list: VBoxContainer = %OptionsBigList

@onready var skin_tab: VBoxContainer = %SkinTab
@onready var skin_options_big_list: VBoxContainer = %SkinOptionsBigList

@onready var char_tab: VBoxContainer = %CharTab
@onready var char_var_list: VarList = %CharVarList

@onready var info_tab: VBoxContainer = %InfoTab
@onready var info_sel_button: Button = %InfoSelButton

@onready var personality_label: Label = %PersonalityLabel


var dropdownVarScene := preload("res://UI/VarList/Vars/dropdown_var.tscn")

var collapseRegionScene := preload("res://UI/collapsable_region.tscn")
var varListScene := preload("res://UI/VarList/VarList.tscn")
var regionRememberOpen:Dictionary = {}

var charCreatorWizardWindow := preload("res://Game/CharacterCreator/char_creator_wizard_window.tscn")

var character:BaseCharacter
var doll:Doll
var cachedDoll:Doll

signal onConfirmPressed

signal onUpdateBaseSkinTypesList

func _ready() -> void:
	#updateSelectedTab()
	#updatePartOptionsList()
	character_creator_camera_setup.setCharCreator(self)
	setTab("char")
	
	UIHandler.addWindow(save_preset_dialog)
	UIHandler.addWindow(load_preset_dialog)
	tree_exiting.connect(func():
		UIHandler.removeWindow(save_preset_dialog)
		UIHandler.removeWindow(load_preset_dialog)
	)
	pass

func setCharacter(newChar:BaseCharacter):
	if(character != null && is_instance_valid(character)):
		resetCharacterPose()
		character.onChange.disconnect(onCharChange)
	character = newChar
	doll = null
	cachedDoll = null
	if(character != null && is_instance_valid(character)):
		character.onChange.connect(onCharChange)
	
	updateSelectedTab()
	updatePartsList()
	updatePartOptionsList()
	updateCharTab()
	
	character_creator_camera_setup.setZone(zoneFilter)
	character_creator_camera_setup._process(0.0)
	#showWizardWindow()

func onCharChange(_change:BaseCharChange):
	var theType := _change.getType()
	
	match theType:
		BaseCharChange.PART:
			triggerUpdateAll()
		BaseCharChange.PART_OPTION:
			if(_change.optionID == "skinType"):
				onUpdateBaseSkinTypesList.emit()
			pass
		BaseCharChange.CHAR_OPTION:
			if(_change.optionID == CharOption.skinTypes):
				onUpdateBaseSkinTypesList.emit()
			pass
		BaseCharChange.PART_FILTER:
			pass
		BaseCharChange.PRESET_APPLIED:
			triggerUpdateAll()
			updateCharTab()

var isUpdatingAll:bool = false
func triggerUpdateAll():
	if(isUpdatingAll):
		return
	isUpdatingAll = true
	await get_tree().process_frame
	updatePartsList()
	updatePartOptionsList()
	updateCategoryOptions()
	updateCategoryButtonsList()
	isUpdatingAll = false

func getChar() -> BaseCharacter:
	return character

func getCharacter() -> BaseCharacter:
	return character

func updateSelectedTab():
	parts_sel_button.text = "[ Parts ]" if currentTab == "parts" else "Parts"
	options_sel_button.text = "[ Options ]" if currentTab == "options" else "Options"
	skin_sel_button.text = "[ Skin&Colors ]" if currentTab == "skin" else "Skin&Colors"
	char_sel_button.text = "[ Base ]" if currentTab == "char" else "Base"
	info_sel_button.text = "[ Info ]" if currentTab == "info" else "Info"
	
	parts_tab.visible = (currentTab == "parts")
	options_tab.visible = (currentTab == "options")
	skin_tab.visible = (currentTab == "skin")
	char_tab.visible = (currentTab == "char")
	info_tab.visible = (currentTab == "info")

func setTab(_newTab:String):
	currentTab = _newTab
	updateSelectedTab()

	if(currentTab == "skin"):
		updateSkinTab()
	if(currentTab == "char"):
		updateCharTab()
	if(currentTab == "info"):
		updateInfoTab()
	updateCategoryOptions()
	updateCategoryButtonsList()
	setZoneFilter(CharCreatorZone.ALL)
	#updateSelectedZoneFilter()

func _on_parts_sel_button_pressed() -> void:
	setTab("parts")

func _on_options_sel_button_pressed() -> void:
	setTab("options")

func _on_skin_sel_button_pressed() -> void:
	setTab("skin")

func updateSkinTab():
	updatePartOptionsListGeneric(skin_options_big_list, "skin")

func updateCharTab():
	if(!character):
		char_var_list.setVars({})
		return
	var theOptions:Dictionary = {}
	var theCharOptions:Dictionary = character.getCharOptions()
	for charOptionID in theCharOptions:
		var theOption:Dictionary = theCharOptions[charOptionID]
		var theEditors:Array = theOption["editors"] if theOption.has("editors") else [GenericPart.EDITOR_PART]
		if(!theEditors.has(GenericPart.EDITOR_PART)):
			continue
		theOptions[charOptionID] = theOption
	char_var_list.setVars(theOptions)

func changeSkinTypeDataColor(skinType:int, theColor:Color):
	if(character == null):
		return
	
	var skinTypes:Dictionary = character.getAllUsedSkinTypes()
	if(!skinTypes.has(skinType)):
		return
	
	var skinTypeData:SkinTypeData = skinTypes[skinType].makeCopy()
	skinTypeData.color = theColor
	#character.triggerUpdateAllSkinTypes()

	GM.characterRegistry.askCharacterChangeBaseSkinTypeData(character, skinType, skinTypeData)
	
#
#func chanceSkinTypeDataBodypartColor(theColor:Color, bodypartSlot:int):
	#if(character == null):
		#return
	#
	#var bodypart:BodypartBase = character.getBodypart(bodypartSlot)
	#if(bodypart.skinDataOverride == null):
		#return
	#var newSkinData:SkinTypeData = bodypart.skinDataOverride.makeCopy()
	##bodypart.skinDataOverride.color = theColor
	##character.triggerUpdateAllSkinTypes()
	#newSkinData.color = theColor
	#GM.characterRegistry.askCharacterPartOptionChange(character, BaseCharacter.GENERIC_BODYPARTS, bodypartSlot, "skinDataOverride", newSkinData)

#func onSkinTypeOverrideSelected(skinTypeIndex:int, bodypartSlot:int):
	#if(character == null):
		#return
	#
	#var bodypart:BodypartBase = character.getBodypart(bodypartSlot)
#
	#var selectedSkinType:int = bodypart.getSupportedSkinTypes().keys()[skinTypeIndex]
	#var newSkinTypeData:SkinTypeData = null
	#if(bodypart.skinDataOverride != null):
		#newSkinTypeData = bodypart.skinDataOverride.makeCopy()
		##newSkinTypeData.skinType = selectedSkinType
	#GM.characterRegistry.askCharacterPartOptionChange(character, BaseCharacter.GENERIC_BODYPARTS, bodypartSlot, selectedSkinType, newSkinTypeData)
	#GM.characterRegistry.askCharacterBodypartSkinTypeChange(character, bodypartSlot, selectedSkinType, newSkinTypeData)
	##bodypart.skinType = selectedSkinType
	##if(bodypart.skinDataOverride != null):
	##	bodypart.skinDataOverride.skinType = selectedSkinType
	##character.updateAllSkinTypes()
	##updateSkinTab()
	##updatePartOptionsList()

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

func onBodypartDropdownPicked(_id:int, _value):
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
	if(currentTab != "options"):
		return
	updatePartOptionsListGeneric(options_big_list, "part")

func updatePartOptionsListGeneric(listNode:Node, optionFilter:String):
	Util.delete_children(listNode)
	
	var isSkin:bool = true#(optionFilter == "skin")
	
	if(character == null):
		return
	
	if(zoneFilter in [CharCreatorZone.Body, CharCreatorZone.ALL]): #isSkin || 
		var skinTypes:Dictionary = character.getAllUsedSkinTypes()
		
		if(!skinTypes.is_empty()):
			#var regionShouldBeOpened:bool = regionRememberOpen["baseColors"] if regionRememberOpen.has("baseColors") else false
			#if(zoneFilter != CharCreatorZone.ALL): #!isSkin && 
			#	regionShouldBeOpened = true
			
			var baseSkinRegion := collapseRegionScene.instantiate()
			listNode.add_child(baseSkinRegion)
			baseSkinRegion.setName("Base colors")
			baseSkinRegion.setOpened(true)#regionShouldBeOpened)
			#if(zoneFilter != CharCreatorZone.ALL):
			#	baseSkinRegion.onOpenToggle.connect(onCollapseOpenToggle.bind("baseColors"))
			
			var theColorsList := preload("res://Game/CharacterCreator/Util/char_creator_base_skin_types_list.tscn").instantiate()
			baseSkinRegion.addNodeInside(theColorsList)
			theColorsList.setProfile(character.skinTypes if character else null)
			theColorsList.onColorChange.connect(changeSkinTypeDataColor)
			
			#for skinType in skinTypes:
				#var skinTypeData:SkinTypeData = skinTypes[skinType]
				#
				#var skinTypeName:String = SkinType.getName(skinType)
				#
				#var theLabel:Label = Label.new()
				#baseSkinRegion.addNodeInside(theLabel)
				#theLabel.text = skinTypeName
#
				#var theColorPicker:ColorPickerButton = ColorPickerButton.new()
				#baseSkinRegion.addNodeInside(theColorPicker)
				#theColorPicker.color = skinTypeData.color
				#theColorPicker.custom_minimum_size.y = 30.0
				#
				#theColorPicker.color_changed.connect(changeSkinTypeDataColor.bind(skinType))

	
	for bodypartSlot in character.getBodyparts():
		var bodypart:BodypartBase = character.getBodypart(bodypartSlot)
		
		var allOptions:Dictionary = bodypart.getOptionsFinal()
		var options:Dictionary = {}
		for optionID in allOptions:
			var optionEntry:Dictionary = allOptions[optionID]
			var optionTypes:Array = optionEntry["editors"] if optionEntry.has("editors") else [GenericPart.EDITOR_PART]
			# Editor type check
			if(!optionTypes.has(optionFilter)):
				continue
			# Zone filter
			if(zoneFilter != CharCreatorZone.ALL): #!isSkin && 
				var editorZone:int = bodypart.getDefaultEditorZone()
				if(optionEntry.has("editorZone")):
					editorZone = optionEntry["editorZone"]
				if(zoneFilter != editorZone):
					continue
			optionEntry["value"] = bodypart.getOptionValue(optionID)
			options[optionID] = optionEntry
		
		var shouldAddStuff:bool = false
		if(!options.is_empty() || (isSkin && bodypart.supportsSkinTypes() && zoneFilter in [CharCreatorZone.ALL, bodypart.getDefaultEditorZone()])):
			shouldAddStuff = true
		
		if(!shouldAddStuff):
			continue
		
		var regionShouldBeOpened:bool = regionRememberOpen[BodypartSlot.getName(bodypartSlot)+"_part"] if regionRememberOpen.has(BodypartSlot.getName(bodypartSlot)+"_part") else false
		if(zoneFilter != CharCreatorZone.ALL): #!isSkin && 
			regionShouldBeOpened = true
		
		var newRegion = collapseRegionScene.instantiate()
		listNode.add_child(newRegion)
		newRegion.setName(bodypart.getEditorName() if !BodypartSlot.hasPair(bodypartSlot) else (BodypartSlot.getName(bodypartSlot)+" - "+bodypart.getEditorName()))
		newRegion.setOpened(regionShouldBeOpened)
		if(!isSkin && zoneFilter != CharCreatorZone.ALL):
			newRegion.onOpenToggle.connect(onCollapseOpenToggle.bind(BodypartSlot.getName(bodypartSlot)+"_part"))

				
		var newVarList:VarList = varListScene.instantiate()
		newRegion.addNodeInside(newVarList)
		newVarList.setVars(options)
		newVarList.onVarChange.connect(onBodypartChangeOption.bind(bodypartSlot))


func onCollapseOpenToggle(newOpen:bool, collapseID:String):
	regionRememberOpen[collapseID] = newOpen

func onBodypartChangeOption(_id:String, value, bodypartSlot:int):
	var bodypart:BodypartBase = character.getBodypart(bodypartSlot)
	if(bodypart == null):
		return
	#bodypart.setOptionValue(_id, value)
	GM.characterRegistry.askCharacterPartOptionChange(character, BaseCharacter.GENERIC_BODYPARTS, bodypartSlot, _id, value)


func _on_confirm_button_pressed() -> void:
	onConfirmPressed.emit()

func _enter_tree() -> void:
	UIHandler.addUI(self, UIHandler.CLOSE_TRYCLOSEMENU_FUNC)

func _exit_tree() -> void:
	resetCharacterPose()
	UIHandler.removeUI(self)

func tryCloseMenu() -> bool:
	onConfirmPressed.emit()
	return true

func _on_char_sel_button_pressed() -> void:
	setTab("char")


func _on_char_var_list_on_var_change(id: String, value: Variant) -> void:
	if(!character):
		return
	GM.characterRegistry.askCharacterSyncOptionChange(character, id, value)
	#character.applyCharChange(id, value)

var wizardWindow:ConfirmationDialog
func _on_wizard_button_pressed() -> void:
	showWizardWindow()

func showWizardWindow():
	if(wizardWindow):
		wizardWindow.queue_free()
		wizardWindow = null
	
	wizardWindow = charCreatorWizardWindow.instantiate()
	add_child(wizardWindow)
	wizardWindow.popup_centered()
	wizardWindow.setData({
		CharOption.name: character.getSyncOptionValue(CharOption.name),
		CharOption.gender: character.getSyncOptionValue(CharOption.gender),
		CharOption.species: character.getSyncOptionValue(CharOption.species),
	})
	wizardWindow.onCancel.connect(onWizardClose)
	wizardWindow.onWizardSubmit.connect(onWizardSubmit)

func onWizardClose(_window):
	if(wizardWindow):
		wizardWindow.queue_free()
		wizardWindow = null

func onWizardSubmit(_window, _data:Dictionary):
	if(wizardWindow):
		wizardWindow.queue_free()
		wizardWindow = null
	
	GM.characterRegistry.askCharacterWizardSubmit(character, _data)

@onready var save_preset_dialog: ConfirmationDialog = %SavePresetDialog
@onready var save_preset_line_edit: LineEdit = %SavePresetLineEdit
@onready var load_preset_dialog: ConfirmationDialog = %LoadPresetDialog
@onready var character_preset_selector: VBoxContainer = %CharacterPresetSelector

func _on_load_preset_button_pressed() -> void:
	if(!character):
		return
	load_preset_dialog.popup_centered()
	#setSelectedPreset.setSelectedPreset()
	#load_preset_list.clear()
	#for preset in GM.presets.userPresets:
	#	load_preset_list.add_item(preset.getEditorName())

func _on_save_preset_button_pressed() -> void:
	if(!character):
		return
	save_preset_dialog.popup_centered()
	if(save_preset_line_edit.text == ""):
		save_preset_line_edit.text = Util.sanitizeFileName(character.getFullName()).replace(" ", "")

func _on_save_preset_dialog_confirmed() -> void:
	if(!character):
		return
	#resetCharacterPose()
	var theName:String = save_preset_line_edit.text
	theName = Util.sanitizeFileName(theName)
	
	var newPreset:CharacterPreset = CharacterPreset.new()
	newPreset.loadFromCharacter(character)
	newPreset.savePreset(theName)
	GM.presets.rescanUserPresets()
	character_preset_selector.updateAll()
	#character_preset_selector.setSelectedPreset()

func _on_load_preset_dialogue_confirmed() -> void:
	if(!character):
		return
	if(character_preset_selector.getSelectedPreset() == null):
		return
	var newPreset:CharacterPreset = character_preset_selector.getSelectedPreset()
	#var newPreset:CharacterPreset = CharacterPreset.new()
	#if(!newPreset.loadPreset("test")):
	#	return
	GM.characterRegistry.askCharacterLoadPreset(character, newPreset)
	save_preset_line_edit.text = Util.sanitizeFileName(newPreset.filename.get_basename().get_file())
	#print(save_preset_line_edit.text)
	pass

func _process(_delta: float) -> void:
	if(character):
		var thePawn := GM.pawnRegistry.getPawn(character.getID())
		if(thePawn):
			doll = thePawn.getDoll().getDoll() if thePawn.getDoll() else null
		else:
			doll = null
	else:
		doll = null
	
	if(cachedDoll != doll):
		# NEW DOLL
		cachedDoll = doll
	
	if(doll):
		character_creator_camera_setup.global_position = doll.global_position
		character_creator_camera_setup.global_rotation.y = doll.global_rotation.y
		
@onready var character_creator_camera_setup: CharacterCreatorCameraSetup = %CharacterCreatorCameraSetup
@onready var dragger_control: Control = %DraggerControl
var controllingCamera:bool = false

func _on_dragger_control_gui_input(event: InputEvent) -> void:
	if(event is InputEventMouseButton):
		#if(event.button_index == MOUSE_BUTTON_LEFT):
			#if(event.pressed):
				#UIHandler.releaseUIFocus()
		if(event.button_index == MOUSE_BUTTON_WHEEL_DOWN):
			character_creator_camera_setup.handleZoom(1.0)
		if(event.button_index == MOUSE_BUTTON_WHEEL_UP):
			character_creator_camera_setup.handleZoom(-1.0)
		
		
		if(event.button_index in [MOUSE_BUTTON_RIGHT, MOUSE_BUTTON_LEFT, MOUSE_BUTTON_MIDDLE]):
			if(event.pressed):
				UIHandler.releaseUIFocus()
				controllingCamera = true
			else:
				controllingCamera = false

func _input(event: InputEvent) -> void:
	if(controllingCamera && event is InputEventMouseMotion):
		var mouseD:Vector2 = event.relative
		character_creator_camera_setup.handleMouseMove(mouseD)

var categoryToSlotToOptions:Dictionary = {}
func updateCategoryOptions():
	categoryToSlotToOptions.clear()
	if(!character):
		return
	if(currentTab != "options"):
		return
	for bodypartSlot in character.getBodyparts():
		var theBodypart:BodypartBase = character.getBodypart(bodypartSlot)
		
		var theOptions := theBodypart.getOptionsFinal()
		#if(!theOptions.is_empty() && !categoryToSlotToOptions.has(bodypartSlot)):
		#	categoryToSlotToOptions[bodypartSlot] = {}
		
		#var cachedOptions:Dictionary = categoryToSlotToOptions[bodypartSlot]
		for optionID in theOptions:
			var theOptionEntry:Dictionary = theOptions[optionID]
			var theEditorZone:int = theBodypart.getDefaultEditorZone()
			if(theOptionEntry.has("editorZone")):
				theEditorZone = theOptionEntry["editorZone"]
			if(theEditorZone == CharCreatorZone.NOTHING):
				continue
			if(!categoryToSlotToOptions.has(theEditorZone)):
				categoryToSlotToOptions[theEditorZone] = {}
			var zoneCacheOptions:Dictionary = categoryToSlotToOptions[theEditorZone]
			if(!zoneCacheOptions.has(bodypartSlot)):
				zoneCacheOptions[bodypartSlot] = {}
			var cachedOptions:Dictionary = zoneCacheOptions[bodypartSlot]
			cachedOptions[optionID] = theOptionEntry

var categoryToButton:Dictionary[int, Button] = {}
@onready var category_buttons_list: VBoxContainer = %CategoryButtonsList
@onready var filter_panel: PanelContainer = %FilterPanel

func updateCategoryButtonsList():
	Util.delete_children(category_buttons_list)
	categoryToButton.clear()
	
	if(currentTab != "options"):
		filter_panel.visible = false
		return
	filter_panel.visible = true
	
	var aButton:Button = Button.new()
	aButton.text = "All"
	category_buttons_list.add_child(aButton)
	categoryToButton[CharCreatorZone.ALL] = aButton
	aButton.pressed.connect(setZoneFilter.bind(CharCreatorZone.ALL))
	
	for zone in CharCreatorZone.ORDER:
		if(!categoryToSlotToOptions.has(zone)):
			continue
		var zoneName:String = CharCreatorZone.getName(zone)
		
		var newButton:Button = Button.new()
		newButton.text = zoneName
		category_buttons_list.add_child(newButton)
		categoryToButton[zone] = newButton
		newButton.pressed.connect(setZoneFilter.bind(zone))

func setZoneFilter(_zone:int):
	zoneFilter = _zone
	character_creator_camera_setup.setZone(zoneFilter)
	updateSelectedZoneFilter()
	if(currentTab == "options"):
		updatePartOptionsList()
	if(character):
		if(_zone == CharCreatorZone.Legs):
			GM.characterRegistry.askCharacterSyncOptionChange(character, CharOption.idlePose, "ShowFoot")
		else:
			GM.characterRegistry.askCharacterSyncOptionChange(character, CharOption.idlePose, "")
		if(_zone == CharCreatorZone.Hands):
			GM.characterRegistry.askCharacterSyncOptionChange(character, CharOption.poseArms, "ShowHands")
		else:
			GM.characterRegistry.askCharacterSyncOptionChange(character, CharOption.poseArms, "")
	if(doll):
		if(_zone == CharCreatorZone.Mouth):
			doll.setMouthOpenTemporary(true)
		else:
			doll.setMouthOpenTemporary(false)
		
func updateSelectedZoneFilter():
	for zone in categoryToButton:
		categoryToButton[zone].disabled = (zoneFilter == zone)

func resetCharacterPose():
	if(!character):
		return
	GM.characterRegistry.askCharacterSyncOptionChange(character, CharOption.idlePose, "")
	GM.characterRegistry.askCharacterSyncOptionChange(character, CharOption.poseArms, "")
	if(doll):
		doll.setMouthOpenTemporary(false)

func _on_info_sel_button_pressed() -> void:
	setTab("info")

func updateInfoTab():
	if(!character):
		return
	var thePersAr:Array[String] = []
	for statID in GlobalRegistry.getPersonalityStatIDsSorted():
		var thePersStat:PersonalityStatBase = GlobalRegistry.getPersonalityStat(statID)
		if(!thePersStat):
			continue
		thePersAr.append(thePersStat.getVisibleName()+": "+str(Util.roundF(character.personality.getStat(statID), 2)))
	personality_label.text = Util.join(thePersAr, "\n")

const PERSONALITY_EDIT_PANEL = preload("res://Game/CharacterCreator/PersonalityEditUI/personality_edit_panel.tscn")

func _on_edit_personality_button_pressed() -> void:
	var newPanel := PERSONALITY_EDIT_PANEL.instantiate()
	add_child(newPanel)
	newPanel.setPersonalityCopy(character.personality)
	newPanel.onCancel.connect(func(): newPanel.queue_free())
	newPanel.onSave.connect(onPersEditApply.bind(newPanel))

func onPersEditApply(_pers:Personality, _control:Control):
	_control.queue_free()
	GM.characterRegistry.askCharacterSetPersonality(character, _pers)
	#character.personality.loadData(_pers.saveData().duplicate(true))
	updateInfoTab()

const FETISHES_EDIT_PANEL = preload("res://Game/CharacterCreator/FetishesEditUI/fetishes_edit_panel.tscn")

func _on_edit_fetishes_button_pressed() -> void:
	var newPanel := FETISHES_EDIT_PANEL.instantiate()
	add_child(newPanel)
	newPanel.setFetishHolderCopy(character.fetishHolder)
	newPanel.onCancel.connect(func(): newPanel.queue_free())
	newPanel.onSave.connect(onFetishEditApply.bind(newPanel))

func onFetishEditApply(_fetishes:FetishHolder, _control:Control):
	_control.queue_free()
	GM.characterRegistry.askCharacterSetFetishHolder(character, _fetishes)
	updateInfoTab()

func _on_open_preset_button_pressed() -> void:
	OS.shell_open(ProjectSettings.globalize_path(CharacterPresetHolder.USERPRESETS_FOLDER))
