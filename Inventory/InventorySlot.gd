extends Object
class_name InventorySlot

const Hat = "Hat"
const Chest = "Chest"
const Legs = "Legs"

static func getAll() -> Array:
	return [Hat, Chest, Legs]

static func getVisibleName(slot) -> String:
	return slot
