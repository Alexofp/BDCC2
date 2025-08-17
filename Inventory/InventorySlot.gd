extends Object
class_name InventorySlot

const Eyes = 0
const Mouth = 1
const Collar = 2
const Top = 3
const Bottom = 4
const Suit = 5
const Wrists = 6
const Ankles = 7
const Nipples = 8
const UnderwearTop = 9
const UnderwearBottom = 10

const ALL = [Eyes, Mouth, Collar, Top, Bottom, Suit, Wrists, Ankles, Nipples, UnderwearTop, UnderwearBottom]
const NAMES = ["Eyes", "Mouth", "Collar", "Top", "Bottom", "Suit", "Wrists", "Ankles", "Nipples", "Underwear (top)", "Underwear (bottom)"]

static func getAll() -> Array:
	return ALL

static func getName(_slot:int) -> String:
	if(_slot < 0 || _slot >= NAMES.size()):
		return "Error!BadSlot:"+str(_slot)
	return NAMES[_slot]
