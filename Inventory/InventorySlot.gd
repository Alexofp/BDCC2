extends Object
class_name InventorySlot

const Hat = "Hat"
const Chest = "Chest"
const Legs = "Legs"
const UnderwearBottom = "UnderwearBottom"
const UnderwearTop = "UnderwearTop"

static func getAll() -> Array:
	return [Hat, Chest, Legs, UnderwearBottom, UnderwearTop]

static func getVisibleName(slot) -> String:
	return slot
