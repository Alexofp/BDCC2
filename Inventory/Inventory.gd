extends RefCounted
class_name Inventory

var charRef:WeakRef

var equipped:Dictionary[int, ItemBase] = {}

signal onEquippedItemChange(slot, newItem)
signal onEquippedItemOptionChange(optionID, value, part, slot)

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

func saveNetworkData() -> Dictionary:
	return {}

func loadNetworkData(_data:Dictionary):
	pass
