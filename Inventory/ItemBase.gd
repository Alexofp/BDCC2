extends GenericPart
class_name ItemBase

#var id:String = ""
var uniqueID:int = 0

var invRef:WeakRef
var currentSlot:int = -1

var staticBuffs:Array[Buff]
var buffsNeedUpdate:bool = true

func _init():
	super._init()

func getName() -> String:
	return id+":"+str(uniqueID)

func getDescription() -> String:
	return "Fill me!"

func getDescriptionFinal() -> String:
	var theBuffsDesc := getBuffsDescription()
	var theOptionsDesc := getInteractOptionsDescription()
	
	var result:String = getDescription()
	
	if(!theOptionsDesc.is_empty()):
		result = Util.join(theOptionsDesc, "\n")+"\n"+result
	if(!theBuffsDesc.is_empty()):
		result += "\n\n"+theBuffsDesc
	
	return result

func getBuffsDescription() -> String:
	var theBuffs := getBuffs()
	if(theBuffs.is_empty()):
		return ""
	var result:String = ""
	for theBuff in theBuffs:
		if(theBuff.invisible):
			continue
		if(!result.is_empty()):
			result += "\n"
		result += "[color=#"+theBuff.getColor().to_html(false)+"]"+theBuff.getName()+" "+theBuff.getBuffText()+"[/color]"
	return result
	
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

func isInInventory() -> bool:
	if(getInventory()):
		return true
	return false

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

func removeSelf() -> bool:
	var theInv:Inventory = getInventory()
	if(!theInv):
		return false
	return theInv.removeItem(self)

func unequipSelf() -> bool:
	if(!isEquipable() || !isEquipped()):
		return false
	var theInv:Inventory = getInventory()
	if(!theInv):
		return false
	return theInv.unequipSlot(currentSlot)

func equipSelf() -> bool:
	if(!isEquipable() || isEquipped()):
		return false
	var theInv:Inventory = getInventory()
	if(!theInv):
		return false
	return getInventory().equipItemFreeSlot(self)

func itemAction(_name:String, _desc:String, _actionID:String, _args:Array = []) -> Array:
	return [true, _name, _desc, _actionID, _args]

func itemActionDisabled(_name:String, _desc:String) -> Array:
	return [false, _name, _desc]

func getActions() -> Array:
	return []

#Runs on server
func tryDoActionSelf(_id:String, _args:Array):
	doActionFinal(_id, _args)

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
		theActions.append(itemAction("Drop", "Drop the item!", "drop"))
	
	theActions.append_array(getActions())
	
	return theActions

#Runs on server
func doActionFinal(_id:String, _args:Array):
	if(_id == "equip"):
		equipSelf()
	elif(_id == "unequip"):
		unequipSelf()
	elif(_id == "drop"):
		if(!getInventory()):
			removeSelf()
			return
		var theChar := getInventory().getChar()
		removeSelf()
		if(theChar):
			var theCharID:String = theChar.getID()
			var thePawn:CharacterPawn = GM.pawnRegistry.getPawn(theCharID)
			if(thePawn):
				GM.inventoryRegistry.spawnItem(thePawn.global_position, self)
	else:
		doAction(_id, _args)

func getDisplaceActions(_context:Dictionary) -> Array[Dictionary]:
	return []

func doDisplaceAction(_id:String, _args:Array, _context:Dictionary):
	doActionFinal(_id, _args)

func canUnequipInSex(_context:Dictionary) -> bool:
	if(!isEquipable()):
		return false
	if(isBondageGear()):
		return false
	var theEquipSlots := getSlotsToEquipTo()
	for theSlot in theEquipSlots:
		if(theSlot in [InventorySlot.Bottom, InventorySlot.Top, InventorySlot.UnderwearBottom, InventorySlot.UnderwearTop, InventorySlot.Suit]):
			return true
	return false

func shouldAutoEquipAfterSex() -> bool:
	return true

func resetEquippedState():
	pass

func onAutoEquipAfterSex():
	resetEquippedState()

func isBondageGear() -> bool:
	return false

func isStrapon() -> bool:
	return false

const EQUIP_OK = 0
const EQUIP_SLOT_OCCUPIED = 1
const EQUIP_MISSING_BODYPART = 2 #Trying to equip a chastity cage onto a character with no penis or something
const EQUIP_UNABLE_TO = 3 # Generic 'can't equip this item' error

func canBeEquippedOntoReason(theInv:Inventory) -> int:
	if(!isEquipable() || !theInv):
		return EQUIP_UNABLE_TO
	var theSlots := getSlotsToEquipTo()
	var hasFreeSlotToUse:bool = false
	var _hasMissingSlots:bool = false
	for invSlot in theSlots:
		if(theInv.unableToUseSlot(invSlot)):
			_hasMissingSlots = true
			continue
		if(theInv.hasSlotEquipped(invSlot)):
			continue
		hasFreeSlotToUse = true
		break
	if(hasFreeSlotToUse):
		return EQUIP_OK
	if(_hasMissingSlots):
		return EQUIP_MISSING_BODYPART
	return EQUIP_SLOT_OCCUPIED

func getCanBeEquippedOntoReasonText(_reason:int) -> String:
	if(_reason == EQUIP_OK):
		return ""
	if(_reason == EQUIP_MISSING_BODYPART):
		return "Unable to equip because of a missing required bodypart"
	if(_reason == EQUIP_SLOT_OCCUPIED):
		return "Unable to equip because the slot is already occupied"
	if(_reason == EQUIP_UNABLE_TO):
		return "Unable to equip this item"
	
	return "Unable to equip for an unknown reason"

func canBeEquippedOnto(_theInv:Inventory) -> bool:
	return canBeEquippedOntoReason(_theInv) == EQUIP_OK

func getCoveredZones() -> Dictionary[int, bool]:
	return {}

func isZoneCovered(_zone:int) -> bool:
	var theZones := getCoveredZones()
	if(theZones.has(_zone)):
		return theZones[_zone]
	return false

func getZoneLayer() -> float:
	var theSlot := getSlot()
	if(theSlot >= 0):
		return ZoneLayer.getDefaultFromInvSlot(theSlot)
	
	var theSlots := getSlotsToEquipTo()
	if(theSlots.is_empty()):
		return -1.0
	return ZoneLayer.getDefaultFromInvSlot(theSlots[0])

func getLeashTargets() -> Array[String]:
	return []

func getLeashTargetName(_id:String) -> String:
	return _id

func prepareBuffs() -> Array[Buff]:
	return []

func getBuffs() -> Array[Buff]:
	if(buffsNeedUpdate):
		buffsNeedUpdate = false
		staticBuffs = prepareBuffs()
	return staticBuffs

func getPawn() -> CharacterPawn:
	var theChar := getCharacter()
	if(!theChar):
		return null
	var thePawn := theChar.getPawn()
	if(!thePawn):
		return null
	return thePawn

func startDelayedDoAction(_text:String, _timer:float, _id:String, _args:Array):
	var thePawn := getPawn()
	if(!thePawn):
		return
	var newEntry := ActionSystemEntry.new()
	
	var mainTarget := ActionSystemTarget.new()
	mainTarget.node = thePawn
	
	#newEntry.actionText = _text
	newEntry.user = thePawn
	newEntry.target = mainTarget
	newEntry.action = GlobalRegistry.getPawnAction("ItemActionDelayed")# self
	newEntry.timeFull = _timer
	newEntry.args = [uniqueID, _id, _args]
	
	#for extra in _extras:
	#	newEntry.addExtraTarget(extra)
	
	newEntry.setActionText(_text)
	GM.actionSystem.startAction(newEntry)

func playGesture(_gesture:String):
	var thePawn := getPawn()
	if(!thePawn):
		return
	thePawn.playGesture(_gesture)

func doDelayedDisplaceAction(_anim:String, _time:float, _actionID:String, _args:Array, _text:String):
	var thePawn := getPawn()
	if(thePawn):
		if(thePawn.isDoingSomething() || thePawn.isDoingSex()):
			return
	playGesture(_anim)
	startDelayedDoAction(_text, _time, _actionID, _args)

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
