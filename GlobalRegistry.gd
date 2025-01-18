extends Object
class_name GlobalRegistry # and so we meet again

static var wasInit = false

static var bodyparts: Dictionary = {}
static var bodypartRefs: Dictionary = {}


static func doInit():
	if(wasInit):
		return
	wasInit = true
	registerBodypartsFolder("res://Game/Character/Bodyparts/Body/")
	
	Log.Print("GlobalRegistry: Registered everything")


static func registerBodypart(path: String):
	var loadedClass = load(path)
	var object = loadedClass.new()
	
	bodyparts[object.id] = loadedClass
	bodypartRefs[object.id] = object

static func registerBodypartsFolder(folder: String):
	var scripts = Util.getScriptsInFolder(folder)
	for scriptPath in scripts:
		registerBodypart(scriptPath)

static func createBodypart(id: String) -> BodypartBase:
	if(bodyparts.has(id)):
		return bodyparts[id].new()
	else:
		Log.Printerr("ERROR: bodypart with the id "+str(id)+" wasn't found")
		return null

static func getBodyparts():
	return bodypartRefs

static func getBodypartRef(id: String) -> BodypartBase:
	if(bodypartRefs.has(id)):
		return bodypartRefs[id]
	else:
		Log.Printerr("ERROR: bodypart with the id "+str(id)+" wasn't found")
		return null

static func getBodypartIDsForSlot(bodypartSlot:String):
	var result:Array = []
	
	for bodypartID in bodypartRefs:
		if(bodypartRefs[bodypartID].supportsSlot(bodypartSlot)):
			result.append(bodypartID)
	
	return result

static func getBodypartIDsOfType(bodypartType:String):
	var result:Array = []
	
	for bodypartID in bodypartRefs:
		if(bodypartRefs[bodypartID].getBodypartType() == bodypartType):
			result.append(bodypartID)
	
	return result
