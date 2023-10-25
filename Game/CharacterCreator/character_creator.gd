extends Control

@onready var partsPanel = $HBoxContainer/VBoxContainer/PartsPanel
@onready var bodypartsList = $HBoxContainer/VBoxContainer/PartsPanel/BodypartsList
@onready var skinPanel = $HBoxContainer/VBoxContainer/SkinPanel
@onready var skinpartsList = $HBoxContainer/VBoxContainer/SkinPanel/SkinOptionsList/BodypartsList
@onready var baseSkinDataPanel = $HBoxContainer/VBoxContainer/SkinPanel/SkinOptionsList/BaseSkinData

var bodypartPanelScene = preload("res://Game/CharacterCreator/Elements/bodypart_panel.tscn")

var character: BaseCharacter

func hideAllPanels():
	partsPanel.visible = false
	skinPanel.visible = false

func _ready():
	_on_parts_menu_button_pressed()

func setCharacter(newChar: BaseCharacter):
	character = newChar
	character.onBodypartOptionsRecalculated.connect(onCharacterBodypartOptionsRecalculated)
	
	updateCharacter()

func updateCharacter():
	Util.delete_children(bodypartsList)
	Util.delete_children(skinpartsList)
	
	baseSkinDataPanel.setValue(character.getBaseSkinData())
	
	var partsToCheck = [character.getRootBodypart()]
	
	while(partsToCheck.size() != 0):
		var part:BaseBodypart = partsToCheck.pop_back()
		
		if(true):
			var newBodypartScene = bodypartPanelScene.instantiate()
			bodypartsList.add_child(newBodypartScene)
			newBodypartScene.setLabel(part.getVisibleName())
			newBodypartScene.setBodypart(part)
			newBodypartScene.parentPart = part.getParentBodypart()
			if(newBodypartScene.parentPart != null):
				newBodypartScene.parentPartSlot = newBodypartScene.parentPart.getSlotOfPart(part)
			newBodypartScene.onChildBodypartChangeType.connect(onChildBodypartChangeType)
		if(true):
			var newBodypartScene = bodypartPanelScene.instantiate()
			newBodypartScene.isSkinOptions = true
			skinpartsList.add_child(newBodypartScene)
			newBodypartScene.setLabel(part.getVisibleName())
			newBodypartScene.setBodypart(part)
			newBodypartScene.parentPart = part.getParentBodypart()
			if(newBodypartScene.parentPart != null):
				newBodypartScene.parentPartSlot = newBodypartScene.parentPart.getSlotOfPart(part)
			#newBodypartScene.onChildBodypartChangeType.connect(onChildBodypartChangeType)
		
		for bodypartSlot in part.getBodypartSlots():
			if(part.hasBodypart(bodypartSlot)):
				partsToCheck.append(part.getBodypart(bodypartSlot))

func onCharacterBodypartOptionsRecalculated(_part):
	updateCharacter()

func onChildBodypartChangeType(part:BaseBodypart, slot, newtype):
	if(part.hasBodypart(slot)):
		part.removeBodypart(slot)
	
	if(newtype != null):
		var newPart = GlobalRegistry.createBodypart(newtype)
		if(newPart != null):
			part.setBodypart(slot, newPart)
	updateCharacter()

func _on_parts_menu_button_pressed():
	hideAllPanels()
	partsPanel.visible = true

func _on_skin_menu_button_pressed():
	hideAllPanels()
	skinPanel.visible = true


func _on_base_skin_data_on_value_change(_id, newValue):
	if(character == null):
		return
	character.setBaseSkinData(newValue)
