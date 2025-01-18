extends Object
class_name BodypartType

const Body = "Body"
const Head = "Head"
const Ear = "Ear"
const Hair = "Hair"
const Horn = "Horn"
const Tail = "Tail"
const Penis = "Penis"

const ALL = [
	Body, Head, Ear, Hair, Horn, Tail, Penis,
]

static func getAll() -> Array:
	return ALL

static func getName(slot:String):
	return slot
