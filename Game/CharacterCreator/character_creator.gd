extends Control

@onready var bodypartsList = $HBoxContainer/VBoxContainer/ScrollContainer/BodypartsList

var bodypartPanelScene = preload("res://Game/CharacterCreator/Elements/bodypart_panel.tscn")

var character: BaseCharacter

func _ready():
	pass # Replace with function body.

func setCharacter(newChar: BaseCharacter):
	character = newChar
	
	updateCharacter()

func updateCharacter():
	Util.delete_children(bodypartsList)
	
	var partsToCheck = [character.getRootBodypart()]
	
	while(partsToCheck.size() != 0):
		var part:BaseBodypart = partsToCheck.pop_back()
		
		var newBodypartScene = bodypartPanelScene.instantiate()
		bodypartsList.add_child(newBodypartScene)
		newBodypartScene.setLabel(part.getVisibleName())
		newBodypartScene.setBodypart(part)
		newBodypartScene.parentPart = part.getParentBodypart()
		if(newBodypartScene.parentPart != null):
			newBodypartScene.parentPartSlot = newBodypartScene.parentPart.getSlotOfPart(part)
		newBodypartScene.onChildBodypartChangeType.connect(onChildBodypartChangeType)
		
		for bodypartSlot in part.getBodypartSlots():
			if(part.hasBodypart(bodypartSlot)):
				partsToCheck.append(part.getBodypart(bodypartSlot))

func onChildBodypartChangeType(part:BaseBodypart, slot, newtype):
	if(part.hasBodypart(slot)):
		part.removeBodypart(slot)
	
	if(newtype != null):
		var newPart = GlobalRegistry.createBodypart(newtype)
		if(newPart != null):
			part.setBodypart(slot, newPart)
	updateCharacter()
