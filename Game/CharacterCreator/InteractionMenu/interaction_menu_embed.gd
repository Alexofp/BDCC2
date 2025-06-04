extends ScrollContainer

var collapseRegionScene := preload("res://UI/collapsable_region.tscn")
var interactMenuEntry := preload("res://Game/CharacterCreator/InteractionMenu/interact_menu_entry.tscn")
@onready var interact_list: VBoxContainer = %InteractList

var charID:String = ""


func setCharacter(_char:BaseCharacter):
	setCharID(_char.getID() if _char else "")

func setCharID(_charID:String):
	charID = _charID
	updateList()

func getCharacter() -> BaseCharacter:
	return GM.characterRegistry.getCharacter(charID)

func updateList():
	Util.delete_children(interact_list)
	
	var theChar:BaseCharacter = getCharacter()
	if(!theChar):
		return
	
	var theCharOptions:Dictionary = theChar.getCharOptionsFinalWithValues()
	var charInteractOptions:Dictionary = {}
	for optionID in theCharOptions:
		var optionEntry:Dictionary = theCharOptions[optionID]
		var theEditors:Array = optionEntry["editors"] if optionEntry.has("editors") else []
		if(!(theEditors.has(GenericPart.EDITOR_INTERACT))):
			continue
		charInteractOptions[optionID] = optionEntry
	if(!charInteractOptions.is_empty()):
		var theRegion = collapseRegionScene.instantiate()
		interact_list.add_child(theRegion)
		theRegion.setName(theChar.getName())
		
		var theEntry = interactMenuEntry.instantiate()
		theRegion.addNodeInside(theEntry)
		
		theEntry.setName(theChar.getName())
		var theVarList:VarList = theEntry.getVarList()
		theVarList.setVars(charInteractOptions)
		theVarList.onVarChange.connect(onCharVarChange)
			
					
	var theParts:Dictionary = theChar.getGenericParts()
	for genType in theParts:
		for slot in theParts[genType]:
			var thePart:GenericPart = theParts[genType][slot]
			
			var interactOptions:Dictionary = {}
			
			var theOptions:= thePart.getOptionsFinalWithValues()
			
			for optionID in theOptions:
				var optionEntry:Dictionary = theOptions[optionID]
				
				var theEditors:Array = optionEntry["editors"] if optionEntry.has("editors") else []
				if(!(theEditors.has(GenericPart.EDITOR_INTERACT))):
					continue
				
				interactOptions[optionID] = optionEntry
			
			if(interactOptions.is_empty()):
				continue
			var theRegion = collapseRegionScene.instantiate()
			interact_list.add_child(theRegion)
			theRegion.setName(thePart.getName())
			
			var theEntry = interactMenuEntry.instantiate()
			theRegion.addNodeInside(theEntry)
			theEntry.setName(thePart.getName())
			var theVarList:VarList = theEntry.getVarList()
			theVarList.setVars(interactOptions)
			theVarList.onVarChange.connect(onGenericPartVarChange.bind(genType, slot))
				
	#theOptions["piercingsColor"] = {
			#name = "Piercings color",
			#type = "color",
			#editors = [EDITOR_PART],
		#}

func onGenericPartVarChange(_varID:String, _value:Variant, _genType:int, _genSlot:int):
	GM.characterRegistry.askCharacterPartOptionChange(getCharacter(), _genType, _genSlot, _varID, _value)

func onCharVarChange(_varID:String, _value:Variant):
	GM.characterRegistry.askCharacterSyncOptionChange(getCharacter(), _varID, _value)
