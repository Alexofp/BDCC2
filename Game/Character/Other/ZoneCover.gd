extends Object
class_name ZoneCover

const Anything = 0
const Head = 1
const Mouth = 2
const Body = 3
const Breasts = 4
const Nipples = 5
const Penis = 6
const Vagina = 7
const Anus = 8

const ALL = [
	Anything, Head, Mouth, Body,
	Breasts, Nipples, Penis, Vagina, Anus,
]

static func isLewd(_zone:int) -> bool:
	if(_zone in [Breasts, Nipples, Penis, Vagina, Anus]):
		return true
	return false
