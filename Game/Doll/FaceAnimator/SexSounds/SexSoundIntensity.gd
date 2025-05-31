extends Object
class_name SexSoundIntensity

enum {
	Low,
	Medium,
	High,
	#Extreme,
}

static func getAll() -> Array:
	return [Low, Medium, High]#, Extreme

static func toFolderName(_state:int) -> String:
	if(_state == Low):
		return "Low"
	if(_state == Medium):
		return "Medium"
	if(_state == High):
		return "High"
	#if(_state == Extreme):
	#	return "Extreme"
	
	return "ERROR"
