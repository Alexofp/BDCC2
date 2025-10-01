extends RefCounted
class_name Inventory

var charRef:WeakRef

var equipped:Dictionary[int, ItemBase] = {}

signal onEquippedItemChange(slot:int, newItem:ItemBase)
signal onEquippedItemOptionChange(optionID:String, value:Variant, part:ItemBase, slot:int)

func removeEquippedItem(_slot:int) -> ItemBase:
	if(!equipped.has(_slot)):
		return null
	var theItem:ItemBase = equipped[_slot]
	theItem.setInventory(null)
	theItem.onOptionChanged.disconnect(onItemOptionChangeCallback.bind(theItem, _slot))
	equipped.erase(_slot)
	onEquippedItemChange.emit(_slot, null)
	return theItem

func setEquippedItem(_slot:int, _item:ItemBase):
	if(equipped.has(_slot)):
		removeEquippedItem(_slot)
	if(_item == null):
		return
	if(_item.invRef):
		assert(false, "Item already has an inventory attached to it!")
		return
	equipped[_slot] = _item
	_item.setInventory(self)
	_item.onOptionChanged.connect(onItemOptionChangeCallback.bind(_item, _slot))
	onEquippedItemChange.emit(_slot, _item)

func onItemOptionChangeCallback(optionID:String, value, _part:ItemBase, slot:int):
	onEquippedItemOptionChange.emit(optionID, value, _part, slot)

func canEquipReason(_slot:int, _item:ItemBase) -> Array:
	if(hasSlotEquipped(_slot)):
		return [false, "This slot already has something in it"]
	if(_item == null):
		return [false, "Unable to equip non-existant item"]
	if(!(_slot in _item.getSlotsToEquipTo())):
		return [false, "This item can not be equipped into this slot"]
	return [true, ""]

func hasSlotEquipped(_slot:int) -> bool:
	return equipped.has(_slot)

func setCharacter(_character:BaseCharacter):
	if(_character == null):
		charRef = null
		return
	charRef = weakref(_character)

func getChar() -> BaseCharacter:
	if(charRef == null):
		return null
	return charRef.get_ref()

func getCharacter() -> BaseCharacter:
	if(charRef == null):
		return null
	return charRef.get_ref()

func getEquippedItem(_slot:int) -> ItemBase:
	if(!equipped.has(_slot)):
		return null
	return equipped[_slot]

func getEquippedItems() -> Dictionary:
	return equipped

func shouldHobbleLegs() -> bool:
	for slot in equipped:
		var theItem:ItemBase = equipped[slot]
		if(theItem.shouldHobbleLegs()):
			return true
	return false

func saveNetworkData() -> Bins:
	var ar:Array = [
		Bins.I32, equipped.size(),
	]
	
	for invSlot in equipped:
		var theItem:ItemBase = equipped[invSlot]
		ar.append_array([Bins.I8, invSlot])
		ar.append_array([Bins.StrShort, theItem.id])
		ar.append_array([Bins.I32, theItem.uniqueID])
		ar.append_array([Bins.BINS, theItem.saveNetworkData()])
	
	var data:= Bins.saveStart(ar)
	return data.endSave()

func loadNetworkData(_data:Bins):
	_data.loadStart()
	for invSlot in equipped.keys():
		removeEquippedItem(invSlot)
	equipped.clear()
	
	var theItemAmount:int = _data.readI32()
	for _i in range(theItemAmount):
		var invSlot:int = _data.readI8()
		var itemID:String = _data.readStrShort()
		var uid:int = _data.readI32()
		var itemData:Bins = _data.readBins()
		
		var theItem:ItemBase = GlobalRegistry.createItem(itemID, false)
		if(!theItem):
			continue
		theItem.uniqueID = uid
		theItem.loadNetworkData(itemData)
		setEquippedItem(invSlot, theItem)
	
	_data.endLoad()

func saveData() -> Dictionary:
	var equippedData:Dictionary = {}
	for invSlot in equipped:
		var theItem:ItemBase = equipped[invSlot]
		equippedData[invSlot] = {
			id = theItem.id,
			uid = theItem.uniqueID,
			data = theItem.saveData(),
		}
	
	return {
		equipped = equippedData,
	}

func loadData(_data:Dictionary):
	for invSlot in equipped.keys():
		removeEquippedItem(invSlot)
	equipped.clear()
	
	var equippedData:Dictionary = SAVE.loadVar(_data, "equipped", {})
	for invSlot in equippedData:
		var itemData:Dictionary = equippedData[invSlot]
		var itemID:String = SAVE.loadVar(itemData, "id", "")
		var uid:int = SAVE.loadVar(itemData, "uid", 0)
		var theItem:ItemBase = GlobalRegistry.createItem(itemID, false)
		theItem.uniqueID = uid
		theItem.loadData(SAVE.loadVar(itemData, "data", {}))
		setEquippedItem(invSlot, theItem)
