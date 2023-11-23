extends Object
class_name InventorySlot

const Chest = "Chest"
const Legs = "Legs"

static func getAll() -> Array:
	return [Chest, Legs]

static func getVisibleName(slot) -> String:
	return slot
