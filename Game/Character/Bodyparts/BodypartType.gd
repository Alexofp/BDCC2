extends Object
class_name BodypartType

enum {
	Body, Head, Ear, Hair, Horn, Tail, Penis,
}
const ALL = [
	Body, Head, Ear, Hair, Horn, Tail, Penis,
]
const NAMES = [
	"Body", "Head", "Ear", "Hair", "Horn", "Tail", "Penis",
]

static func getAll() -> Array:
	return ALL

static func getName(slot:int) -> String:
	if(slot < 0 || slot >= NAMES.size()):
		return "ERROR:BADTYPE:"+str(slot)
	return NAMES[slot]
