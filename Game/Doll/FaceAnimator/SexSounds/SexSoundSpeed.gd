extends Object
class_name SexSoundSpeed

enum {
	Slow,
	Medium,
	Fast,
}

static func getAll() -> Array:
	return [Slow, Medium, Fast]

static func toFolderName(_state:int) -> String:
	if(_state == Slow):
		return "Slow"
	if(_state == Medium):
		return "Medium"
	if(_state == Fast):
		return "Fast"
	
	return "ERROR"
