extends Object
class_name SexSoundMouth

enum {
	Opened,
	Closed,
	#Gagged,
}

static func getAll() -> Array:
	return [Opened, Closed]

static func toFolderName(_state:int) -> String:
	if(_state == Opened):
		return "Open"
	if(_state == Closed):
		return "Closed"
	
	return "ERROR"
