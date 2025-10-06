extends GenericPart
class_name ItemBase

#var id:String = ""
var uniqueID:int = 0

var invRef:WeakRef
var currentSlot:int = -1

func _init():
	super._init()

func getName() -> String:
	return id+":"+str(uniqueID)

func getDescription() -> String:
	return "Fill me!"

func getDescriptionFinal() -> String:
	var theOptionsDesc := getInteractOptionsDescription()
	if(!theOptionsDesc.is_empty()):
		return Util.join(theOptionsDesc, "\n")+"\n"+getDescription()
	return getDescription()

func getInteractOptionsDescription() -> Array[String]:
	var result:Array[String] = []
	
	var theOptions := getOptionsFinalWithValues()
	for optionID in theOptions:
		var theEntry:Dictionary = theOptions[optionID]
		if(!theEntry.has("value")):
			continue
		var theEditors:Array = theEntry["editors"] if theEntry.has("editors") else []
		if(!(theEditors.has(GenericPart.EDITOR_INTERACT))):
			continue
		var theName:String = theEntry["name"] if theEntry.has("name") else str(optionID)
		var theValue:Variant = theEntry["value"]
		if(theValue is int):
			result.append(theName+": "+str(theValue))
		elif(theValue is float):
			result.append(theName+": "+str(round(theValue*10.0)/10.0))
		elif(theValue is String):
			result.append(theName+": "+str(theValue))
		elif(theValue is Color):
			result.append(theName+": [outline_size=8][outline_color=#444444][color=#"+theValue.to_html(false)+"]"+str(theValue.to_html())+"[/color][/outline_color][/outline_size]")
		elif(theValue is bool):
			result.append(theName+": "+("yes" if theValue else "no"))
	return result

func getSlotsToEquipTo() -> Array[int]:
	var theSlot:int = getSlot()
	if(theSlot >= 0):
		return [theSlot]
	return []

func getSlot() -> int:
	return -1

func isEquipable() -> bool:
	return getSlot() >= 0

func isEquipped() -> bool:
	return currentSlot >= 0

func canBeEquippedToAnySlot() -> bool:
	if(isEquipped()):
		return false
	
	var theInv:Inventory = getInventory()
	if(!theInv):
		return false
	for theSlot in getSlotsToEquipTo():
		if(!theInv.hasSlotEquipped(theSlot)):
			return true
	return false

func getInventory() -> Inventory:
	if(!invRef):
		return null
	return invRef.get_ref()

func setInventory(_inv:Inventory):
	if(_inv == null):
		invRef = null
		return
	invRef = weakref(_inv)

func getCharacter() -> BaseCharacter:
	var theInv:Inventory = getInventory()
	if(theInv == null):
		return null
	return theInv.getCharacter()

func getClothingSelectorPaths() -> Array:
	return []
#
#func getScenePathForItemID(_itemID:String) -> String:
	#for clothingSelectorA in GlobalRegistry.getClothingSelectors():
		#var clothingSelector:ClothingSceneSelector = clothingSelectorA
		#
		##if(clothingSelector.)
	#return ""

func getScenePathForCharacter(_slot:int, _theChar:BaseCharacter) -> String:
	if(!_theChar):
		return ""
	for clothingSelectorA in GlobalRegistry.getClothingSelectors():
		var clothingSelector:ClothingSceneSelector = clothingSelectorA
		
		if(clothingSelector.itemID != id):
			continue
		
		for bodypartID in clothingSelector.sceneByBodypartID:
			if(_theChar.hasBodypartID(bodypartID)):
				return clothingSelector.sceneByBodypartID[bodypartID]
		
	return ""

func getScenePath(_slot:int) -> String:
	return getScenePathForCharacter(_slot, getCharacter())

func shouldHobbleLegs() -> bool:
	return false

func getSexHideTags() -> Dictionary:
	return {}

func removeSelf():
	var theInv:Inventory = getInventory()
	if(!theInv):
		return
	theInv.removeItem(self)

func itemAction(_name:String, _desc:String, _actionID:String, _args:Array = []) -> Array:
	return [true, _name, _desc, _actionID, _args]

func itemActionDisabled(_name:String, _desc:String) -> Array:
	return [false, _name, _desc]

func getActions() -> Array:
	return []

#Runs on server
func doAction(_id:String, _args:Array):
	pass

func getActionsFinal() -> Array:
	var theActions:Array = []
	
	if(isEquipable()):
		if(!isEquipped()):
			if(canBeEquippedToAnySlot()):
				theActions.append(itemAction("Equip", "Put the item on", "equip"))
			else:
				theActions.append(itemActionDisabled("Equip", "You already have something equipped in this slot"))
		else:
			theActions.append(itemAction("Unequip", "Take the item off", "unequip"))
	
	if(!isEquipped()):
		theActions.append(itemAction("Drop", "Destroy the item!", "drop"))
	
	theActions.append_array(getActions())
	
	return theActions

#Runs on server
func doActionFinal(_id:String, _args:Array):
	if(_id == "equip"):
		getInventory().equipItemFreeSlot(self)
	elif(_id == "unequip"):
		getInventory().unequipSlot(currentSlot)
	elif(_id == "drop"):
		removeSelf()
	else:
		doAction(_id, _args)

func saveNetworkData() -> Bins:
	var data := super.saveNetworkData()
	data.saveContinue([
		Bins.I32, uniqueID,
	])
	return data.endSave()

func loadNetworkData(_data:Bins):
	super.loadNetworkData(_data)
	_data.loadStart()
	uniqueID = _data.readI32()
	_data.endLoad()

func saveData() -> Dictionary:
	var _data:Dictionary = super.saveData()

	_data["uniqueID"] = uniqueID
	
	return _data

func loadData(_data:Dictionary):
	super.loadData(_data)
	
	uniqueID = SAVE.loadVar(_data, "uniqueID", -1)
