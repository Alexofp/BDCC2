extends Object
class_name BodypartSlot

const Body = "Body"
const Head = "Head"
const LeftEar = "LeftEar"
const RightEar = "RightEar"
const Hair = "Hair"
const LeftHorn = "LeftHorn"
const RightHorn = "RightHorn"
const Tail = "Tail"
const Penis = "Penis"

const ALL = [
	Body, Head, LeftEar, RightEar, Hair, LeftHorn, RightHorn, Tail, Penis,
]

static func getAll() -> Array:
	return ALL

static func getName(slot:String):
	return slot

static func getFromType(bodypartType:String) -> Array:
	if(bodypartType == BodypartType.Ear):
		return [LeftEar, RightEar]
	if(bodypartType == BodypartType.Horn):
		return [LeftHorn, RightHorn]
	if(bodypartType == ""):
		return []
	return [bodypartType]
