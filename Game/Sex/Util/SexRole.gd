extends Object
class_name SexRole

const Dom := 0
const Sub := 1

static func getName(_role:int) -> String:
	if(_role == Dom):
		return "Dominant"
	if(_role == Sub):
		return "Submissive"
	return "Unknown"
