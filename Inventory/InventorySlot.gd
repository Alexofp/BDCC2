extends Object
class_name InventorySlot

enum {
	Eyes,
	Mouth,
	Collar,
	Top,
	Bottom,
	Wrists,
	Ankles,
	Nipples,
	UnderwearTop,
	UnderwearBottom,
}

const ALL = [Eyes, Mouth, Collar, Top, Bottom, Wrists, Ankles, Nipples, UnderwearTop, UnderwearBottom]
const NAMES = ["Eyes", "Mouth", "Collar", "Top", "Bottom", "Wrists", "Ankles", "Nipples", "Underwear (top)", "Underwear (bottom)"]

static func getAll() -> Array:
	return ALL

static func getName(_slot:int) -> String:
	if(_slot < 0 || _slot >= NAMES.size()):
		return "Error!BadSlot:"+str(_slot)
	return NAMES[_slot]
