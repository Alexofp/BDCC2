extends Object
class_name BodypartSlot

const Body = "Body"
const Head = "Head"
const LeftEar = "LeftEar"
const RightEar = "RightEar"
const Legs = "Legs"

static func getAll() -> Array:
	return [Body, Head, LeftEar, RightEar, Legs]

static func getVisibleName(slot):
	if(slot == LeftEar):
		return "Left ear"
	if(slot == RightEar):
		return "Right ear"
	
	return str(slot)
