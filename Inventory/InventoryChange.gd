extends RefCounted
class_name InventoryChange

const EQUIPPED = 0
const UNEQUIPPED = 1
const ITEM_ADDED = 2
const ITEM_REMOVED = 3
const OPTION_CHANGED = 4

var invRef:WeakRef
var invUID:int = -1

var changeType:int = -1
var slot:int
var data

func getType() -> int:
	return changeType

func getSlot() -> int:
	return slot

func equippedGetItem() -> ItemBase:
	return data

func getInvUID() -> int:
	return invUID

func addedGetItem() -> ItemBase:
	return data

func removedGetItem() -> ItemBase:
	return data

static func makeEquipped(_inv:Inventory, _slot:int, _newItem:ItemBase) -> InventoryChange:
	var newChange := InventoryChange.new()
	newChange.invUID = _inv.uniqueID
	newChange.invRef = weakref(_inv)
	newChange.changeType = EQUIPPED
	newChange.slot = _slot
	newChange.data = _newItem
	return newChange

static func makeUnequipped(_inv:Inventory, _slot:int) -> InventoryChange:
	var newChange := InventoryChange.new()
	newChange.invUID = _inv.uniqueID
	newChange.invRef = weakref(_inv)
	newChange.changeType = UNEQUIPPED
	newChange.slot = _slot
	return newChange

static func makeOptionChanged(_inv:Inventory, optionID:String, value:Variant, part:ItemBase, _slot:int) -> InventoryChange:
	var newChange := InventoryChange.new()
	newChange.invUID = _inv.uniqueID
	newChange.invRef = weakref(_inv)
	newChange.changeType = OPTION_CHANGED
	newChange.slot = _slot
	newChange.data = [optionID, value, part]
	return newChange

static func makeItemAdded(_inv:Inventory, _item:ItemBase) -> InventoryChange:
	var newChange := InventoryChange.new()
	newChange.invUID = _inv.uniqueID
	newChange.invRef = weakref(_inv)
	newChange.changeType = ITEM_ADDED
	newChange.data = _item
	return newChange

static func makeItemRemoved(_inv:Inventory, _item:ItemBase) -> InventoryChange:
	var newChange := InventoryChange.new()
	newChange.invUID = _inv.uniqueID
	newChange.invRef = weakref(_inv)
	newChange.changeType = ITEM_REMOVED
	newChange.data = _item
	return newChange

func optionChangedGetOptionID() -> String:
	return data[0]

func optionChangedGetValue() -> Variant:
	return data[1]

func optionChangedGetPart() -> ItemBase:
	return data[2]
