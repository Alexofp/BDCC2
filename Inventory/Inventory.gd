extends RefCounted
class_name Inventory

var charRef:WeakRef

var uniqueID:int = -1

var equipped:Dictionary[int, ItemBase] = {}
var items:Array[ItemBase] = []

signal onEquippedItemChange(slot:int, newItem:ItemBase)
signal onEquippedItemOptionChange(optionID:String, value:Variant, part:ItemBase, slot:int)
signal onChange(_change:InventoryChange)

func register():
	GM.inventoryRegistry.registerInventory(self)

func unregister():
	GM.inventoryRegistry.unregisterInventory(self)

func getEquippedItems() -> Dictionary[int, ItemBase]:
	return equipped

func getItems() -> Array[ItemBase]:
	return items

func hasSlotEquipped(_slot:int) -> bool:
	if(!equipped.has(_slot)):
		return false
	return true

func hasItemEquipped(theItem:ItemBase) -> bool:
	if(theItem.getInventory() != self):
		return false
	if(theItem.currentSlot >= 0):
		var theExistingItem := getEquippedItem(theItem.currentSlot)
		if(theExistingItem == theItem):
			return true
	return false

func hasItem(theItem:ItemBase) -> bool:
	return hasItemEquipped(theItem) || hasItemStored(theItem)

func hasItemStored(theItem:ItemBase) -> bool:
	if(theItem.getInventory() != self):
		return false
	return items.has(theItem)

func findItemByUniqueID(_uid:int) -> ItemBase:
	for slot in equipped:
		if(equipped[slot].uniqueID == _uid):
			return equipped[slot]
	for theItem in items:
		if(theItem.uniqueID == _uid):
			return theItem
	return null

func removeItem(theItem:ItemBase) -> bool:
	assert(theItem.getInventory() == self, "BAD ITEM OR INVENTORY")
	if(theItem.currentSlot >= 0):
		var theExistingItem := getEquippedItem(theItem.currentSlot)
		if(theExistingItem == theItem):
			clearSlot(theItem.currentSlot)
			return true
		else:
			assert(false, "SOMETHING WENT WRONG!")
	
	if(!items.has(theItem)):
		return false
	
	theItem.setInventory(null)
	theItem.currentSlot = -1
	items.erase(theItem)
	onChange.emit(InventoryChange.makeItemRemoved(self, theItem))
	return true

func addItem(_item:ItemBase):
	if(_item == null):
		return
	assert(_item.getInventory() == null, "Item already has an inventory attached to it!")
	items.append(_item)
	_item.currentSlot = -1
	_item.setInventory(self)
	onChange.emit(InventoryChange.makeItemAdded(self, _item))

func clearSlot(_slot:int) -> ItemBase:
	if(!equipped.has(_slot)):
		return null
	var theItem:ItemBase = equipped[_slot]
	theItem.setInventory(null)
	theItem.onOptionChanged.disconnect(onItemOptionChangeCallback.bind(theItem, _slot))
	theItem.currentSlot = -1
	equipped.erase(_slot)
	onEquippedItemChange.emit(_slot, null)
	onChange.emit(InventoryChange.makeUnequipped(self, _slot))
	return theItem

func equipItemFreeSlot(_item:ItemBase) -> bool:
	var thePossibleSlots := _item.getSlotsToEquipTo()
	for theSlot in thePossibleSlots:
		if(equipItem(_item, theSlot)):
			return true
	return false

func equipItem(_item:ItemBase, _slot:int) -> bool:
	if(hasSlotEquipped(_slot)):
		return false
	_item.removeSelf()
	setEquippedItem(_slot, _item)
	return true

func unequipSlot(_slot:int) -> bool:
	if(!hasSlotEquipped(_slot)):
		return false
	var theItem:ItemBase = getEquippedItem(_slot)
	theItem.removeSelf()
	addItem(theItem)
	return true

func setEquippedItem(_slot:int, _item:ItemBase):
	if(equipped.has(_slot)):
		clearSlot(_slot)
	if(_item == null):
		return
	if(_item.invRef):
		assert(false, "Item already has an inventory attached to it!")
		return
	equipped[_slot] = _item
	_item.setInventory(self)
	_item.currentSlot = _slot
	_item.onOptionChanged.connect(onItemOptionChangeCallback.bind(_item, _slot))
	onEquippedItemChange.emit(_slot, _item)
	onChange.emit(InventoryChange.makeEquipped(self, _slot, _item))

func onItemOptionChangeCallback(optionID:String, value, _part:ItemBase, slot:int):
	onEquippedItemOptionChange.emit(optionID, value, _part, slot)
	onChange.emit(InventoryChange.makeOptionChanged(self, optionID, value, _part, slot))

func canEquipReason(_slot:int, _item:ItemBase) -> Array:
	if(hasSlotEquipped(_slot)):
		return [false, "This slot already has something in it"]
	if(_item == null):
		return [false, "Unable to equip non-existant item"]
	if(!(_slot in _item.getSlotsToEquipTo())):
		return [false, "This item can not be equipped into this slot"]
	return [true, ""]

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

func shouldHobbleLegs() -> bool:
	for slot in equipped:
		var theItem:ItemBase = equipped[slot]
		if(theItem.shouldHobbleLegs()):
			return true
	return false

func saveNetworkData() -> Bins:
	var ar:Array = [
		Bins.I32, uniqueID,
		Bins.I32, equipped.size(),
	]
	
	for invSlot in equipped:
		var theItem:ItemBase = equipped[invSlot]
		ar.append_array([Bins.I8, invSlot])
		ar.append_array([Bins.StrShort, theItem.id])
		ar.append_array([Bins.I32, theItem.uniqueID])
		ar.append_array([Bins.BINS, theItem.saveNetworkData()])
	
	return Bins.saveStartEnd(ar)

func loadNetworkData(_data:Bins):
	_data.loadStart()
	for invSlot in equipped.keys():
		clearSlot(invSlot)
	equipped.clear()
	
	GM.inventoryRegistry.registerNetworkInventory(self, _data.readI32())
	
	var theItemAmount:int = _data.readI32()
	for _i in range(theItemAmount):
		var invSlot:int = _data.readI8()
		var itemID:String = _data.readStrShort()
		var uid:int = _data.readI32()
		var itemData:Bins = _data.readBins()
		
		var theItem:ItemBase = GlobalRegistry.createItem(itemID, false)
		if(!theItem):
			continue
		theItem.currentSlot = invSlot
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
		uniqueID = uniqueID,
		equipped = equippedData,
	}

func loadData(_data:Dictionary):
	GM.inventoryRegistry.registerNetworkInventory(self, SAVE.loadVar(_data, "uniqueID", -1))
	
	for invSlot in equipped.keys():
		clearSlot(invSlot)
	equipped.clear()
	
	var equippedData:Dictionary = SAVE.loadVar(_data, "equipped", {})
	for invSlot in equippedData:
		var itemData:Dictionary = equippedData[invSlot]
		var itemID:String = SAVE.loadVar(itemData, "id", "")
		var uid:int = SAVE.loadVar(itemData, "uid", 0)
		var theItem:ItemBase = GlobalRegistry.createItem(itemID, false)
		theItem.currentSlot = invSlot
		theItem.uniqueID = uid
		theItem.loadData(SAVE.loadVar(itemData, "data", {}))
		setEquippedItem(invSlot, theItem)
