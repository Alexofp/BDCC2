extends Object
class_name BodypartSlot

enum {
	Body, Head, LeftEar, RightEar, Hair, LeftHorn, RightHorn, Tail, Penis,
}
const ALL = [
	Body, Head, LeftEar, RightEar, Hair, LeftHorn, RightHorn, Tail, Penis,
]
const NAMES = [
	"Body", "Head", "Left Ear", "Right Ear", "Hair", "Left Horn", "Right Horn", "Tail", "Penis",
]

static func getAll() -> Array:
	return ALL

static func getName(slot:int) -> String:
	if(slot < 0 || slot >= NAMES.size()):
		return "ERROR:BADSLOT:"+str(slot)
	return NAMES[slot]

static func getFromType(bodypartType:int) -> Array:
	match bodypartType:
		BodypartType.Ear:
			return [LeftEar, RightEar]
		BodypartType.Horn:
			return [LeftHorn, RightHorn]
		BodypartType.Body:
			return [Body]
		BodypartType.Head:
			return [Head]
		BodypartType.Hair:
			return [Hair]
		BodypartType.Tail:
			return [Tail]
		BodypartType.Penis:
			return [Penis]
	return []
