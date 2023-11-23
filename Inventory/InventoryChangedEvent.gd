extends RefCounted
class_name InventoryChangedEvent

enum {
	ItemAdded,
	ItemRemoved,
	ItemEquipped,
	ItemUnequipped,
}
static func eventTypeToString(theEventType) -> String:
	if(theEventType == ItemAdded):
		return "ItemAdded"
	if(theEventType == ItemRemoved):
		return "ItemRemoved"
	if(theEventType == ItemEquipped):
		return "ItemEquipped"
	if(theEventType == ItemUnequipped):
		return "ItemUnequipped"
	return "ERROR:BAD_EVENT_TYPE:("+str(theEventType)+")"

var eventType
var item:ItemBase
var slot

func getReadableType() -> String:
	return InventoryChangedEvent.eventTypeToString(eventType)

func getReadableInfo() -> String:
	var info = {
		type = getReadableType(),
	}
	if(slot != null && slot != ""):
		info["slot"] = slot
	if(item != null):
		info["item"] = item.id
	return var_to_str(info)

static func createItemAdded(theItem:ItemBase) -> InventoryChangedEvent:
	var newEvent = InventoryChangedEvent.new()
	newEvent.eventType = ItemAdded
	newEvent.item = theItem
	return newEvent
static func createItemRemoved(theItem:ItemBase) -> InventoryChangedEvent:
	var newEvent = InventoryChangedEvent.new()
	newEvent.eventType = ItemRemoved
	newEvent.item = theItem
	return newEvent
static func createItemEquipped(theslot, theItem:ItemBase) -> InventoryChangedEvent:
	var newEvent = InventoryChangedEvent.new()
	newEvent.eventType = ItemEquipped
	newEvent.slot = theslot
	newEvent.item = theItem
	return newEvent
static func createItemUnequipped(theslot, theItem:ItemBase) -> InventoryChangedEvent:
	var newEvent = InventoryChangedEvent.new()
	newEvent.eventType = ItemUnequipped
	newEvent.slot = theslot
	newEvent.item = theItem
	return newEvent
