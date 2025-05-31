extends Object
class_name FluidsOnBodyZone

enum {
	Face,
	Chest,
	Belly,
	Back,
	Waist,
	Butt,
	Legs,
	Arms,
}

const ALL = [Face, Chest, Belly, Back, Waist, Butt, Legs, Arms]
const NAMES = ["Face", "Chest", "Belly", "Back", "Waist", "Butt", "Legs", "Arms"]

static func getAll() -> Array:
	return ALL

static func getName(_zone:int) -> String:
	if(_zone < 0 || _zone >= ALL.size()):
		return "ERROR?"
	return NAMES[_zone]
