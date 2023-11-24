extends RefCounted
class_name Inventory

var items:Array = []
var equippedItems:Dictionary = {}

var charRef:WeakRef

signal itemAdded(newItem)
signal itemRemoved(removedItem)
signal itemEquipped(slot, newItem)
signal itemUnequipped(slot, removedItem)
signal inventoryChanged(inventoryChangedEvent)

func setCharacter(theCharacter: BaseCharacter):
	if(theCharacter == null):
		charRef = null
		return
	charRef = weakref(theCharacter)

func getCharacter() -> BaseCharacter:
	if(charRef == null):
		return null
	return charRef.get_ref()

func addItem(newItem:ItemBase) -> bool:
	if(newItem == null || newItem.currentInventory != null):
		return false
	
	items.append(newItem)
	newItem.currentInventory = self
	emit_signal("itemAdded", newItem)
	emit_signal("inventoryChanged", InventoryChangedEvent.createItemAdded(newItem))
	return true

func hasItem(theItem:ItemBase) -> bool:
	if(theItem != null && items.has(theItem)):
		return true
	return false

func removeItem(theItem:ItemBase) -> bool:
	if(!hasItem(theItem)):
		return false
	theItem.currentInventory = null
	items.erase(theItem)
	emit_signal("itemRemoved", theItem)
	emit_signal("inventoryChanged", InventoryChangedEvent.createItemRemoved(theItem))
	return true

func isSlotEquipped(inventorySlot) -> bool:
	if(equippedItems.has(inventorySlot)):
		return true
	return false

func isItemEquipped(theItem:ItemBase) -> bool:
	if(theItem != null && equippedItems.values().has(theItem)):
		return true
	return false

func equipItem(newItem:ItemBase) -> bool:
	if(newItem == null || newItem.currentInventory != null):
		return false
	var slots = newItem.getItemSlots()
	
	for slot in slots:
		if(!isSlotEquipped(slot)):
			newItem.currentInventory = self
			equippedItems[slot] = newItem
			emit_signal("itemEquipped", slot, newItem)
			emit_signal("inventoryChanged", InventoryChangedEvent.createItemEquipped(slot, newItem))
			return true
	
	return false

func removeEquippedItem(theItem:ItemBase) -> bool:
	for inventorySlot in equippedItems.keys():
		if(equippedItems[inventorySlot] == theItem):
			theItem.currentInventory = null
			equippedItems.erase(inventorySlot)
			emit_signal("itemUnequipped", inventorySlot, theItem)
			emit_signal("inventoryChanged", InventoryChangedEvent.createItemUnequipped(inventorySlot, theItem))
			return true
	
	return false

func clearSlot(inventorySlot):
	if(!isSlotEquipped(inventorySlot)):
		return false
	return removeEquippedItem(equippedItems[inventorySlot])

func getEquippedItems() -> Dictionary:
	return equippedItems
